import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';
import '../widgets/student_widgets.dart';
import '../widgets/remark_history.dart';
import '../services/campus_repository.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.item,
    required this.onBack,
    this.repository,
  });
  final CampusRepository? repository;
  final Complaint item;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => StudentPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to complaints'),
        ),
        const SizedBox(height: 8),
        const Label('COMPLAINT DETAILS'),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: const TextStyle(
            color: ink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                item.id,
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(item.status),
          ],
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complaint overview',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 19),
              Info('Category', item.category.label),
              Info('Assigned to', item.department.label),
              Info(
                'Submitted',
                '${item.date.day}/${item.date.month}/${item.date.year}',
              ),
              const Divider(color: border),
              const SizedBox(height: 13),
              const Text(
                'Your description',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              Text(
                item.details,
                style: const TextStyle(color: muted, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Progress('Submitted', true),
              Progress(
                'In progress',
                item.status == ComplaintStatus.inProgress ||
                    item.status == ComplaintStatus.resolved,
              ),
              Progress(
                item.status == ComplaintStatus.rejected
                    ? 'Rejected'
                    : 'Resolved',
                item.status == ComplaintStatus.resolved ||
                    item.status == ComplaintStatus.rejected,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department response',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              if (repository != null)
                RemarkHistory(
                  key: ValueKey(item.id),
                  repository: repository!,
                  complaintId: item.id,
                )
              else
                Text(
                  item.response ?? 'No response yet. Updates will appear here.',
                  style: TextStyle(
                    color: item.response == null ? muted : ink,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
