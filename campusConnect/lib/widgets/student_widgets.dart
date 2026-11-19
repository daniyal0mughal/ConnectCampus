import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: light ? Colors.white : teal,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.forum_rounded,
          color: light ? teal : Colors.white,
          size: 22,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'campusconnect',
        style: TextStyle(
          color: light ? Colors.white : ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
      ),
    ],
  );
}

class SideLink extends StatelessWidget {
  const SideLink(this.icon, this.text, this.active, this.onTap, {super.key});
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Material(
      color: active ? mist : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: active ? teal : muted, size: 21),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: active ? teal : muted,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class StudentPage extends StatelessWidget {
  const StudentPage({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1030),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 38,
            vertical: MediaQuery.sizeOf(context).width < 600 ? 25 : 40,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: teal,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.7,
    ),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
    ),
  );
}

class Heading extends StatelessWidget {
  const Heading(this.title, this.subtitle, {super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: ink,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: muted)),
    ],
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class Metric extends StatelessWidget {
  const Metric(this.label, this.value, this.icon, {super.key});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Panel(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: mist,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: muted, fontSize: 11),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final ComplaintStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: status.background,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        color: status.color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class ComplaintCard extends StatelessWidget {
  const ComplaintCard({super.key, required this.item, required this.onTap});
  final Complaint item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.id,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            item.title,
            style: const TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.category.label,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(color: border),
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 16,
                color: muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  item.department.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: teal, size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}

class Info extends StatelessWidget {
  const Info(this.label, this.value, {super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class Progress extends StatelessWidget {
  const Progress(this.label, this.active, {super.key});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 17),
    child: Row(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: active ? teal : border,
          size: 23,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: active ? ink : muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
