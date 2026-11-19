import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_case.dart';
import '../models/complaint.dart';
import '../models/user_profile.dart';

class CampusRepository {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<void> registerStudent(
    String name,
    String email,
    String password,
  ) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await completeStudentProfile(credential.user!, name);
  }

  Future<void> completeStudentProfile(User user, String name) async {
    final ref = db.collection('users').doc(user.uid);
    await db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return;
      tx.set(ref, {
        'full_name': name.trim(),
        'email': user.email!,
        'role': 'student',
        'department_id': null,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profile(String uid) =>
      db.collection('users').doc(uid).snapshots();
  Stream<List<AdminCase>> complaints(UserProfile profile) {
    Query<Map<String, dynamic>> query = db.collection('complaints');
    if (profile.role == 'student') {
      query = query.where('student_id', isEqualTo: profile.id);
    }
    if (profile.role == 'dept_admin') {
      query = query.where('department_id', isEqualTo: profile.departmentId);
    }
    if (!['student', 'dept_admin', 'super_admin'].contains(profile.role)) {
      return Stream.error(StateError('Unknown account role.'));
    }
    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminCase(
          id: doc.id,
          student: data['student_name'] as String? ?? 'Student',
          title: data['title'] as String,
          details: data['description'] as String,
          category: categoryFromDocumentId(data['category_id'] as String),
          department: Department.values.byName(data['department_id'] as String),
          status: ComplaintStatus.values.firstWhere(
            (s) => s.databaseValue == data['status'],
          ),
          date: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          remark: data['latest_remark'] as String?,
        );
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
      return items;
    });
  }

  String requestId() => db.collection('_ids').doc().id;
  Future<String> createComplaint(
    Department department,
    Category category,
    String title,
    String description,
    String requestId,
  ) async {
    final user = auth.currentUser!;
    final ref = db.collection('complaints').doc('${user.uid}_$requestId');
    await db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return;
      final profile = await tx.get(db.collection('users').doc(user.uid));
      final route = await tx.get(
        db.collection('categories').doc(category.documentId(department)),
      );
      if (!route.exists) throw StateError('Category is not configured.');
      tx.set(ref, {
        'student_id': user.uid,
        'student_name': profile.data()!['full_name'],
        'category_id': category.documentId(department),
        'department_id': route.data()!['department_id'],
        'title': title.trim(),
        'description': description.trim(),
        'status': 'Pending',
        'rejection_reason': null,
        'latest_remark': null,
        'last_remark_id': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
    return ref.id;
  }

  Future<void> updateComplaint(
    String id,
    ComplaintStatus status,
    String remark,
    String requestId,
  ) async {
    final user = auth.currentUser!;
    final complaint = db.collection('complaints').doc(id);
    final reply = db
        .collection('complaint_remarks')
        .doc('${user.uid}_$requestId');
    await db.runTransaction((tx) async {
      final existing = await tx.get(complaint);
      if (!existing.exists) throw StateError('Complaint no longer exists.');
      // Checking the immutable reply also handles a retry after a newer update.
      final savedReply = await tx.get(reply);
      if (savedReply.exists) {
        if (savedReply.data()!['complaint_id'] != id) {
          throw StateError('This request belongs to another complaint.');
        }
        return;
      }
      final profile = await tx.get(db.collection('users').doc(user.uid));
      tx.update(complaint, {
        'status': status.databaseValue,
        'latest_remark': remark.trim(),
        'rejection_reason': status == ComplaintStatus.rejected
            ? remark.trim()
            : null,
        'last_remark_id': reply.id,
        'updated_at': FieldValue.serverTimestamp(),
      });
      tx.set(reply, {
        'complaint_id': id,
        'admin_id': user.uid,
        'admin_name': profile.data()!['full_name'],
        'remark': remark.trim(),
        'status_set': status.databaseValue,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> createDepartmentAdmin(
    String name,
    String email,
    String password,
    Department department,
  ) async {
    final profile = await db
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();
    if (profile.data()?['role'] != 'super_admin') {
      throw StateError('Administrator permission required.');
    }
    final secondary = await Firebase.initializeApp(
      name: 'provision-${requestId()}',
      options: Firebase.app().options,
    );
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
    User? created;
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      created = credential.user!;
      await db.collection('users').doc(created.uid).set({
        'full_name': name.trim(),
        'email': created.email!,
        'role': 'dept_admin',
        'department_id': department.name,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (created != null) {
        final saved = await db.collection('users').doc(created.uid).get();
        if (!saved.exists) {
          await created.delete();
        } else if (saved.data()?['role'] == 'dept_admin') {
          return;
        }
      }
      rethrow;
    } finally {
      await secondaryAuth.signOut();
      await secondary.delete();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> remarks(String id) => db
      .collection('complaint_remarks')
      .where('complaint_id', isEqualTo: id)
      .snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> departmentAdmins() =>
      db.collection('users').where('role', isEqualTo: 'dept_admin').snapshots();
}

String backendError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email or password is incorrect.',
      'email-already-in-use' =>
        'This email already has an account. Sign in instead.',
      'weak-password' => 'Please choose a stronger password.',
      'invalid-email' => 'Please enter a valid email address.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'user-disabled' =>
        'This account is disabled. Contact your administrator.',
      _ => 'Could not sign in. Check your connection and try again.',
    };
  }
  if (error is FirebaseException && error.code == 'permission-denied') {
    return 'Your account does not have permission for this action.';
  }
  return 'Could not load or save data. Check your connection and try again.';
}
