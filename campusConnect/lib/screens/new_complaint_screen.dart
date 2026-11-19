import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';
import '../widgets/student_widgets.dart';
import '../services/campus_repository.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({
    super.key,
    required this.onSubmit,
    this.live = false,
  });
  final Future<void> Function(Department, Category, String, String) onSubmit;
  final bool live;
  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  Category? category;
  Department? department;
  final title = TextEditingController();
  final details = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    title.dispose();
    details.dispose();
    super.dispose();
  }

  bool busy = false;
  Future<void> submit() async {
    if (department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a department first.')),
      );
      return;
    }
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a complaint category first.')),
      );
      return;
    }
    if (form.currentState?.validate() != true) return;
    setState(() => busy = true);
    try {
      await widget.onSubmit(
        department!,
        category!,
        title.text.trim(),
        details.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(backendError(e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => StudentPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label('MAKE YOUR VOICE HEARD'),
        const SizedBox(height: 8),
        const Heading(
          'New complaint',
          'Tell us what happened. We will route it to the right team.',
        ),
        const SizedBox(height: 22),
        Panel(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1  Choose a department and category',
                  style: TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Both departments offer the same four complaint categories.',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<Department>(
                  key: const Key('complaint_department'),
                  initialValue: department,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: [
                    for (final item in Department.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => setState(() => department = value),
                  validator: (value) =>
                      value == null ? 'Choose a department' : null,
                ),
                const SizedBox(height: 15),
                LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: Category.values.map((item) {
                      final selected = item == category;
                      return SizedBox(
                        width: constraints.maxWidth < 590
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 10) / 2,
                        child: Material(
                          color: selected ? mist : canvas,
                          borderRadius: BorderRadius.circular(13),
                          child: InkWell(
                            onTap: () => setState(() => category = item),
                            borderRadius: BorderRadius.circular(13),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected ? teal : border,
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon, color: teal, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: selected ? teal : muted,
                                    size: 19,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (category != null && department != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: mist,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, color: teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Routed to ${department!.label} · ${category!.label}',
                            style: const TextStyle(
                              color: teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                const Divider(color: border),
                const SizedBox(height: 21),
                const Text(
                  '2  Describe the issue',
                  style: TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 17),
                const FieldLabel('Complaint title'),
                TextFormField(
                  key: const Key('complaint_title'),
                  controller: title,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'A short summary of the issue',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a title'
                      : null,
                ),
                const SizedBox(height: 12),
                const FieldLabel('What happened?'),
                TextFormField(
                  key: const Key('complaint_details'),
                  controller: details,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1200,
                  decoration: const InputDecoration(
                    hintText:
                        'Share the location, time, and helpful details...',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Describe the issue'
                      : null,
                ),
                const SizedBox(height: 12),
                const FieldLabel('Supporting photos'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: canvas,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: teal,
                        size: 28,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Photo attachments are not available in this version.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(busy ? 'Submitting…' : 'Submit complaint'),
                    style: FilledButton.styleFrom(backgroundColor: teal),
                  ),
                ),
                const SizedBox(height: 11),
                Center(
                  child: Text(
                    widget.live
                        ? 'Submitted securely to your department'
                        : 'Preview only · saved for this session',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
