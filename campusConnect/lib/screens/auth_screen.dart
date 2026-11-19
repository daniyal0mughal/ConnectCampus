import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../theme/colors.dart';
import '../widgets/student_widgets.dart';
import 'admin/admin_shell.dart';
import 'super_admin/super_admin_screen.dart';
import 'student_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool admin = false;
  bool superAdmin = false;
  bool register = false;
  bool obscure = true;
  Department department = Department.cs;

  void _preview() => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => superAdmin
          ? const SuperAdminScreen()
          : admin
          ? AdminShell(department: department)
          : const StudentShell(),
    ),
  );

  void _authNotice() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Sign-in will be connected during backend development. Use the preview below.',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 920;
    final form = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!wide) ...[const Brand(), const SizedBox(height: 42)],
              const Label('CAMPUSCONNECT / PORTAL'),
              const SizedBox(height: 12),
              Text(
                superAdmin
                    ? 'See the whole campus.'
                    : admin
                    ? 'Manage your department.'
                    : register
                    ? 'Create your account.'
                    : 'Make campus better.',
                style: const TextStyle(
                  color: ink,
                  fontSize: 39,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                superAdmin
                    ? 'Monitor complaints and compare departments across campus.'
                    : admin
                    ? 'Review student reports, take action, and keep everyone informed.'
                    : 'A simple place to report issues and see what happens next.',
                style: const TextStyle(color: muted, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    _roleChoice(
                      'Student',
                      !admin && !superAdmin,
                      () => setState(() {
                        admin = false;
                        superAdmin = false;
                      }),
                    ),
                    _roleChoice(
                      'Department admin',
                      admin && !superAdmin,
                      () => setState(() {
                        admin = true;
                        superAdmin = false;
                        register = false;
                      }),
                    ),
                    _roleChoice(
                      'Super admin',
                      superAdmin,
                      () => setState(() {
                        superAdmin = true;
                        admin = false;
                        register = false;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (register && !admin && !superAdmin) ...[
                const FieldLabel('Full name'),
                const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Your full name',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (admin) ...[
                const FieldLabel('Department'),
                DropdownButtonFormField<Department>(
                  initialValue: department,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  items: Department.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => department = value);
                  },
                ),
                const SizedBox(height: 16),
              ],
              FieldLabel(
                admin || superAdmin
                    ? 'Administrator email'
                    : 'University email',
              ),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline),
                  hintText: 'name@university.edu',
                ),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Password'),
              TextField(
                obscureText: obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    tooltip: obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _authNotice,
                  style: FilledButton.styleFrom(backgroundColor: teal),
                  child: Text(
                    register && !admin ? 'Create account' : 'Sign in',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (!admin && !superAdmin) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => register = !register),
                    child: Text(
                      register
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: Divider(color: border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'EXPLORE THE DESIGN',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: border)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _preview,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    superAdmin
                        ? 'Preview super admin screens'
                        : admin
                        ? 'Preview department admin screens'
                        : 'Preview student screens',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: teal,
                    side: const BorderSide(color: teal),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Frontend preview uses sample data. Sign-in and storage will be connected later.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: ink,
                      padding: const EdgeInsets.all(52),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Brand(light: true),
                          const Spacer(),
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: amber,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: ink,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Every voice\nshapes this place.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.8,
                            ),
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            'One home for campus issues, clear updates, and meaningful action.',
                            style: TextStyle(
                              color: Color(0xFFB9C9DF),
                              fontSize: 17,
                              height: 1.45,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'REPORT  /  RESPOND  /  RESOLVE',
                            style: TextStyle(
                              color: amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 5, child: form),
                ],
              )
            : form,
      ),
    );
  }

  Widget _roleChoice(String text, bool selected, VoidCallback onTap) =>
      Expanded(
        child: Material(
          color: selected ? ink : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
}
