import 'package:flutter/material.dart';
import '../../services/campus_repository.dart';
import '../../theme/colors.dart';
import '../../widgets/student_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.repository});
  final CampusRepository repository;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool register = false, busy = false, obscure = true;
  String? error;
  @override
  void dispose() {
    for (final c in [name, email, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (register) {
        await widget.repository.registerStudent(
          name.text,
          email.text,
          password.text,
        );
      } else {
        await widget.repository.auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = backendError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> reset() async {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim())) {
      setState(() => error = 'Enter your email above first.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.repository.auth.sendPasswordResetEmail(
        email: email.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'If an account exists, a password-reset email has been sent.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = backendError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Brand(),
                  const SizedBox(height: 32),
                  Heading(
                    register ? 'Create a student account' : 'Welcome back',
                    register
                        ? 'Report campus issues and follow their progress.'
                        : 'Sign in to your CampusConnect account.',
                  ),
                  const SizedBox(height: 24),
                  if (register) ...[
                    const FieldLabel('Full name'),
                    TextFormField(
                      key: const Key('signup_name'),
                      controller: name,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: 'Your full name',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const FieldLabel('Email'),
                  TextFormField(
                    key: const Key('auth_email'),
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    maxLength: 150,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      counterText: '',
                    ),
                    validator: (v) =>
                        v == null ||
                            !RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v.trim())
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Password'),
                  TextFormField(
                    key: const Key('auth_password'),
                    controller: password,
                    obscureText: obscure,
                    autofillHints: [
                      register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: InputDecoration(
                      hintText: register
                          ? 'At least 12 characters'
                          : 'Your password',
                      suffixIcon: IconButton(
                        tooltip: 'Show or hide password',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter your password'
                        : register && (v.length < 12 || v.length > 128)
                        ? 'Use 12–128 characters'
                        : null,
                  ),
                  if (register) ...[
                    const SizedBox(height: 16),
                    const FieldLabel('Confirm password'),
                    TextFormField(
                      key: const Key('signup_confirm'),
                      controller: confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password again',
                      ),
                      validator: (v) =>
                          v != password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Student accounts only. Department administrators receive their account from the super administrator.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: busy ? null : submit,
                      child: Text(
                        busy
                            ? 'Please wait…'
                            : register
                            ? 'Create student account'
                            : 'Sign in',
                      ),
                    ),
                  ),
                  if (!register)
                    TextButton(
                      onPressed: busy ? null : reset,
                      child: const Text('Forgot password?'),
                    ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            register = !register;
                            error = null;
                            password.clear();
                            confirm.clear();
                          }),
                    child: Text(
                      register
                          ? 'Already have an account? Sign in'
                          : 'New student? Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
