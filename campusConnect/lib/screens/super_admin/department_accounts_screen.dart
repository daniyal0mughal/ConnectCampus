import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/complaint.dart';
import '../../services/campus_repository.dart';
import '../../widgets/student_widgets.dart';

class DepartmentAccountsScreen extends StatefulWidget {
  const DepartmentAccountsScreen({super.key, required this.repository});
  final CampusRepository repository;
  @override
  State<DepartmentAccountsScreen> createState() =>
      _DepartmentAccountsScreenState();
}

class _DepartmentAccountsScreenState extends State<DepartmentAccountsScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  Department department = Department.cs;
  bool busy = false;
  String? error;
  late final admins = widget.repository.departmentAdmins();
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> create() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.repository.createDepartmentAdmin(
        name.text,
        email.text,
        password.text,
        department,
      );
      if (!mounted) return;
      name.clear();
      email.clear();
      password.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Department administrator created. Share their credentials securely.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => error = backendError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Panel(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create department administrator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Assign an administrator to one department. This form cannot create super administrators.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter the administrator’s name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email,
                maxLength: 150,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Assigned email'),
                validator: (v) =>
                    v == null ||
                        !RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(v.trim())
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Assigned password',
                  helperText:
                      '12–128 characters. Share securely with the administrator.',
                ),
                validator: (v) => v == null || v.length < 12 || v.length > 128
                    ? 'Use 12–128 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Department>(
                initialValue: department,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Department'),
                items: [
                  for (final c in Department.values)
                    DropdownMenuItem(
                      value: c,
                      child: Text(c.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: busy ? null : (v) => setState(() => department = v!),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: busy ? null : create,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(busy ? 'Creating…' : 'Create administrator'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Department accounts',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: admins,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Could not load administrator accounts.');
          }
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.docs.isEmpty) {
            return const Text('No department administrators yet.');
          }
          return Column(
            children: [
              for (final doc in snapshot.data!.docs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: Text(doc.data()['full_name'] as String),
                  subtitle: Text(
                    '${doc.data()['email']} · ${Department.values.byName(doc.data()['department_id'] as String).label}',
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
