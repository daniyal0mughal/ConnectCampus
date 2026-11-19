import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';
import '../widgets/student_widgets.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({
    super.key,
    required this.items,
    required this.filter,
    required this.onFilter,
    required this.onOpen,
    required this.onNew,
  });
  final List<Complaint> items;
  final ComplaintStatus? filter;
  final ValueChanged<ComplaintStatus?> onFilter;
  final ValueChanged<Complaint> onOpen;
  final VoidCallback onNew;
  @override
  Widget build(BuildContext context) {
    final visible = items
        .where((item) => filter == null || item.status == filter)
        .toList();
    return StudentPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Label('YOUR REPORTS'),
          const SizedBox(height: 8),
          const Heading('My complaints', 'Follow every update from one place.'),
          const SizedBox(height: 22),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterChip('All', filter == null, () => onFilter(null)),
                for (final status in ComplaintStatus.values)
                  filterChip(
                    status.label,
                    filter == status,
                    () => onFilter(status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          if (visible.isEmpty)
            Panel(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, color: teal, size: 34),
                  const SizedBox(height: 9),
                  const Text(
                    'No complaints here yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose another status or create a new complaint.',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onNew,
                    child: const Text('New complaint'),
                  ),
                ],
              ),
            ),
          for (final item in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ComplaintCard(item: item, onTap: () => onOpen(item)),
            ),
        ],
      ),
    );
  }

  Widget filterChip(String label, bool selected, VoidCallback tap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => tap(),
      selectedColor: mist,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? teal : muted,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? teal : border),
    ),
  );
}
