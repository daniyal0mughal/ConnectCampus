import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/campus_repository.dart';
import '../theme/colors.dart';

class RemarkHistory extends StatefulWidget {
  const RemarkHistory({
    super.key,
    required this.repository,
    required this.complaintId,
  });
  final CampusRepository repository;
  final String complaintId;
  @override
  State<RemarkHistory> createState() => _RemarkHistoryState();
}

class _RemarkHistoryState extends State<RemarkHistory> {
  late final stream = widget.repository.remarks(widget.complaintId);
  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text('Could not load reply history.');
      if (!snapshot.hasData) return const LinearProgressIndicator();
      final docs = snapshot.data!.docs.toList()
        ..sort(
          (a, b) =>
              ((a.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
                      0)
                  .compareTo(
                    (b.data()['created_at'] as Timestamp?)
                            ?.millisecondsSinceEpoch ??
                        0,
                  ),
        );
      if (docs.isEmpty) {
        return const Text('No replies yet.', style: TextStyle(color: muted));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final doc in docs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${doc.data()['status_set']} · ${doc.data()['admin_name'] ?? 'Department administrator'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(doc.data()['remark'] as String),
                ],
              ),
            ),
        ],
      );
    },
  );
}
