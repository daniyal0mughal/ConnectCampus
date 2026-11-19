import 'package:campus_connect/screens/auth/sign_in_screen.dart';
import 'package:campus_connect/services/campus_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SignupRepository extends Fake implements CampusRepository {
  List<String>? submitted;
  @override
  Future<void> registerStudent(
    String name,
    String email,
    String password,
  ) async {
    submitted = [name, email, password];
  }
}

void main() {
  testWidgets('student signup validates details and matching passwords', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = SignupRepository();
    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(repository: repository)),
    );
    await tester.tap(find.text('New student? Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create student account'));
    await tester.pumpAndSettle();
    expect(repository.submitted, isNull);
    expect(find.text('Enter a valid email'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('signup_name')),
      'Dana Student',
    );
    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'dana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth_password')),
      'Long-password-123!',
    );
    await tester.enterText(
      find.byKey(const Key('signup_confirm')),
      'different-password',
    );
    await tester.tap(find.text('Create student account'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(repository.submitted, isNull);
    await tester.enterText(
      find.byKey(const Key('signup_confirm')),
      'Long-password-123!',
    );
    await tester.tap(find.text('Create student account'));
    await tester.pumpAndSettle();
    expect(repository.submitted, [
      'Dana Student',
      'dana@example.com',
      'Long-password-123!',
    ]);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });
}
