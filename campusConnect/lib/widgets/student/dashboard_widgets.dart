import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../theme/colors.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.foreground,
    required this.background,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 28,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: foreground, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class NewComplaintShortcut extends StatelessWidget {
  const NewComplaintShortcut({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: ink,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF2B405C),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.add_rounded, color: amber, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New complaint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tell us what needs attention.',
                    style: TextStyle(color: Color(0xFFCCDAEC), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 19,
            ),
          ],
        ),
      ),
    ),
  );
}

class DashboardCategoryTile extends StatelessWidget {
  const DashboardCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (category) {
      Category.cafeteria => (const Color(0xFFFFF2DF), const Color(0xFF925910)),
      Category.library => (const Color(0xFFE7F3ED), const Color(0xFF246F56)),
      Category.labs => (const Color(0xFFEAF0FF), const Color(0xFF2759D7)),
      Category.academic => (const Color(0xFFFDECE6), const Color(0xFFA34C32)),
    };
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(category.icon, color: foreground, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
