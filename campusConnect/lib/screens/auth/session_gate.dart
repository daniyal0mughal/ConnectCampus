import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin_case.dart';
import '../../models/complaint.dart';
import '../../models/user_profile.dart';
import '../../services/campus_repository.dart';
import '../student_shell.dart';
import '../admin/admin_shell.dart';
import '../super_admin/super_admin_screen.dart';
import 'sign_in_screen.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key, this.repository});
  final CampusRepository? repository;
  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final repository = widget.repository ?? CampusRepository();
  late final authStream = repository.auth.authStateChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: authStream,
    builder: (context, auth) {
      if (auth.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (auth.data == null) return SignInScreen(repository: repository);
      return _ProfileGate(
        key: ValueKey(auth.data!.uid),
        repository: repository,
        user: auth.data!,
      );
    },
  );
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate({super.key, required this.repository, required this.user});
  final CampusRepository repository;
  final User user;
  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  late final stream = widget.repository.profile(widget.user.uid);
  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _ErrorPage(
          message: backendError(snapshot.error!),
          repository: widget.repository,
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!snapshot.data!.exists) {
        return _ErrorPage(
          message:
              'Your account setup is incomplete. Contact your administrator. '
              'This screen will update when your account is ready.',
          repository: widget.repository,
        );
      }
      final profile = UserProfile.fromMap(
        widget.user.uid,
        snapshot.data!.data()!,
      );
      if (!['student', 'dept_admin', 'super_admin'].contains(profile.role) ||
          (profile.role == 'dept_admin' &&
              !Department.values.any((c) => c.name == profile.departmentId))) {
        return _ErrorPage(
          message:
              'Your account role is not configured. Contact the administrator.',
          repository: widget.repository,
        );
      }
      return _Workspace(
        key: ValueKey('${profile.id}_${profile.role}_${profile.departmentId}'),
        repository: widget.repository,
        profile: profile,
      );
    },
  );
}

class _Workspace extends StatefulWidget {
  const _Workspace({
    super.key,
    required this.repository,
    required this.profile,
  });
  final CampusRepository repository;
  final UserProfile profile;
  @override
  State<_Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<_Workspace> {
  late final stream = widget.repository.complaints(widget.profile);
  @override
  Widget build(BuildContext context) => StreamBuilder<List<AdminCase>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _ErrorPage(
          message: backendError(snapshot.error!),
          repository: widget.repository,
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final items = snapshot.data!;
      return switch (widget.profile.role) {
        'student' => StudentShell(
          repository: widget.repository,
          profile: widget.profile,
          liveItems: items
              .map(
                (i) => Complaint(
                  i.id,
                  i.title,
                  i.details,
                  i.category,
                  i.status,
                  i.date,
                  i.remark,
                  i.department,
                ),
              )
              .toList(),
        ),
        'dept_admin' => AdminShell(
          department: Department.values.byName(widget.profile.departmentId!),
          repository: widget.repository,
          liveItems: items,
        ),
        _ => SuperAdminScreen(repository: widget.repository, liveItems: items),
      };
    },
  );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.message, required this.repository});
  final String message;
  final CampusRepository repository;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: repository.auth.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    ),
  );
}
