import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';
import '../widgets/student_widgets.dart';
import '../widgets/student/dashboard_widgets.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    required this.items,
    required this.onNew,
    required this.onAll,
  });
  final List<Complaint> items;
  final VoidCallback onNew;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final active = items
        .where(
          (item) =>
              item.status == ComplaintStatus.pending ||
              item.status == ComplaintStatus.inProgress,
        )
        .length;
    final resolved = items
        .where((item) => item.status == ComplaintStatus.resolved)
        .length;
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Label('STUDENT PORTAL'),
                  const SizedBox(height: 6),
                  const Text(
                    'Student dashboard',
                    style: TextStyle(
                      color: ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Report an issue and follow its progress.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Your activity',
                        style: TextStyle(
                          color: ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onAll,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        iconAlignment: IconAlignment.end,
                        label: const Text('View complaints'),
                        style: TextButton.styleFrom(
                          foregroundColor: teal,
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(12) > 17;
                      final columns = largeText && constraints.maxWidth < 480
                          ? 1
                          : 3;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 8) / columns;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: width,
                            child: DashboardStatCard(
                              label: 'Submitted',
                              value: items.length,
                              icon: Icons.article_outlined,
                              foreground: const Color(0xFF2759D7),
                              background: const Color(0xFFE8EFFF),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: DashboardStatCard(
                              label: 'Active',
                              value: active,
                              icon: Icons.schedule_outlined,
                              foreground: const Color(0xFF8A570C),
                              background: const Color(0xFFFFEED1),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: DashboardStatCard(
                              label: 'Resolved',
                              value: resolved,
                              icon: Icons.task_alt_rounded,
                              foreground: const Color(0xFF216B50),
                              background: const Color(0xFFE0F2E8),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  NewComplaintShortcut(onTap: onNew),
                  const SizedBox(height: 24),
                  const Text(
                    'Where can we help?',
                    style: TextStyle(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(13) > 18;
                      final columns = constraints.maxWidth >= 740
                          ? 4
                          : largeText && constraints.maxWidth < 480
                          ? 1
                          : 2;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 8) / columns;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in Category.values)
                            SizedBox(
                              width: width,
                              child: DashboardCategoryTile(
                                category: category,
                                onTap: onNew,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: muted),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Choose your department when you submit a complaint.',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
