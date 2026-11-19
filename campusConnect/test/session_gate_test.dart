import 'dart:async';

import 'package:campus_connect/models/admin_case.dart';
import 'package:campus_connect/models/user_profile.dart';
import 'package:campus_connect/screens/auth/session_gate.dart';
import 'package:campus_connect/screens/super_admin/super_admin_screen.dart';
import 'package:campus_connect/services/campus_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUser extends Fake implements User {
  @override
  String get uid => 'test-account';
}

class TestAuth extends Fake implements FirebaseAuth {
  final changes = StreamController<User?>();
  @override
  Stream<User?> authStateChanges() => changes.stream;
  @override
  Future<void> signOut() async => changes.add(null);
}

// Firebase snapshots are supplied by the SDK; this test double avoids a live database.
// ignore: subtype_of_sealed_class
class TestProfile extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  TestProfile(this.value);
  final Map<String, dynamic>? value;
  @override
  bool get exists => value != null;
  @override
  Map<String, dynamic>? data() => value;
}

class SessionRepository extends Fake implements CampusRepository {
  @override
  final TestAuth auth = TestAuth();
  final profiles = StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> profile(String uid) =>
      profiles.stream;
  @override
  Stream<List<AdminCase>> complaints(UserProfile profile) => Stream.value([]);
}

void main() {
  Future<SessionRepository> openSession(WidgetTester tester) async {
    final repository = SessionRepository();
    addTearDown(repository.auth.changes.close);
    addTearDown(repository.profiles.close);
    await tester.pumpWidget(
      MaterialApp(home: SessionGate(repository: repository)),
    );
    repository.auth.changes.add(TestUser());
    await tester.pump();
    return repository;
  }

  testWidgets('missing profile does not request a student name', (
    tester,
  ) async {
    final repository = await openSession(tester);
    repository.profiles.add(TestProfile(null));
    await tester.pumpAndSettle();
    expect(find.text('Complete your student profile'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('account setup is incomplete'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('super-admin profile opens its dashboard directly', (
    tester,
  ) async {
    final repository = await openSession(tester);
    repository.profiles.add(
      TestProfile({
        'full_name': 'SuperAdmin',
        'email': 'admin@example.com',
        'role': 'super_admin',
        'department_id': null,
      }),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SuperAdminScreen), findsOneWidget);
    expect(find.text('Campus overview'), findsOneWidget);
    expect(find.text('Complete your student profile'), findsNothing);
  });

  testWidgets('a profile arriving after sign-in opens the correct dashboard', (
    tester,
  ) async {
    final repository = await openSession(tester);
    repository.profiles.add(TestProfile(null));
    await tester.pumpAndSettle();
    repository.profiles.add(
      TestProfile({
        'full_name': 'SuperAdmin',
        'email': 'admin@example.com',
        'role': 'super_admin',
        'department_id': null,
      }),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SuperAdminScreen), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
