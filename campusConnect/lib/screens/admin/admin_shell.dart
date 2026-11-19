import 'package:flutter/material.dart';
import '../../models/admin_case.dart';
import '../../models/complaint.dart';
import '../../theme/colors.dart';
import '../../widgets/student_widgets.dart';
import '../auth_screen.dart';
import '../../services/campus_repository.dart';
import '../../widgets/remark_history.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.department,
    this.repository,
    this.liveItems,
  });
  final CampusRepository? repository;
  final List<AdminCase>? liveItems;
  final Department department;
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int tab = 0;
  AdminCase? selected;
  List<AdminCase> get cases => widget.liveItems ?? demoCases;
  late final List<AdminCase> demoCases = demoAdminCases()
      .where((item) => item.department == widget.department)
      .toList();

  void go(int value) => setState(() {
    tab = value;
    selected = null;
  });

  @override
  Widget build(BuildContext context) {
    if (selected != null && widget.liveItems != null) {
      final matching = cases.where((c) => c.id == selected!.id);
      selected = matching.isEmpty ? null : matching.first;
    }
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final active = cases
        .where(
          (item) =>
              item.status == ComplaintStatus.pending ||
              item.status == ComplaintStatus.inProgress,
        )
        .toList();
    final history = cases
        .where(
          (item) =>
              item.status == ComplaintStatus.resolved ||
              item.status == ComplaintStatus.rejected,
        )
        .toList();
    final content = selected != null
        ? AdminDetail(
            key: ValueKey(selected!.id),
            repository: widget.repository,
            item: selected!,
            onBack: () => setState(() => selected = null),
            onSave: (status, remark, requestId) async {
              if (widget.repository != null) {
                await widget.repository!.updateComplaint(
                  selected!.id,
                  status,
                  remark,
                  requestId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Update saved.')),
                  );
                }
                return;
              }
              setState(() {
                selected!.status = status;
                selected!.remark = remark;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Update saved in this preview session.'),
                ),
              );
            },
          )
        : switch (tab) {
            0 => AdminDashboard(
              live: widget.repository != null,
              department: widget.department,
              cases: cases,
              onView: () => go(1),
              onOpen: (item) => setState(() => selected = item),
            ),
            1 => AdminList(
              title: 'Current complaints',
              subtitle: 'Review issues waiting for action.',
              cases: active,
              onOpen: (item) => setState(() => selected = item),
            ),
            _ => AdminList(
              title: 'Previously handled',
              subtitle: 'Resolved and rejected complaints for your department.',
              cases: history,
              onOpen: (item) => setState(() => selected = item),
            ),
          };
    return Scaffold(
      appBar: !wide && widget.repository != null
          ? AppBar(
              title: Text(widget.department.label),
              actions: [
                IconButton(
                  onPressed: _exit,
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  Container(
                    width: 260,
                    color: ink,
                    padding: const EdgeInsets.fromLTRB(20, 27, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Brand(light: true),
                        const SizedBox(height: 42),
                        const Padding(
                          padding: EdgeInsets.only(left: 13, bottom: 12),
                          child: Text(
                            'DEPARTMENT WORKSPACE',
                            style: TextStyle(
                              color: Color(0xFF9FB1CF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        _nav(
                          Icons.space_dashboard_outlined,
                          'Overview',
                          tab == 0 && selected == null,
                          () => go(0),
                        ),
                        _nav(
                          Icons.inbox_outlined,
                          'Current complaints',
                          tab == 1 && selected == null,
                          () => go(1),
                        ),
                        _nav(
                          Icons.history_rounded,
                          'Previously handled',
                          tab == 2 && selected == null,
                          () => go(2),
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF253E60),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SIGNED IN AS',
                                style: TextStyle(
                                  color: Color(0xFF9FB1CF),
                                  fontSize: 10,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.department.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _nav(
                          Icons.logout_rounded,
                          widget.repository == null
                              ? 'Leave preview'
                              : 'Sign out',
                          false,
                          _exit,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: mist,
              selectedIndex: tab,
              onDestinationSelected: go,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inbox_outlined),
                  label: 'Current',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
              ],
            ),
    );
  }

  void _exit() {
    if (widget.repository != null) {
      widget.repository!.auth.signOut();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }

  Widget _nav(IconData icon, String text, bool active, VoidCallback tap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: active ? const Color(0xFF35598F) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: tap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: active ? Colors.white : const Color(0xFFB2C0D4),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFB2C0D4),
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
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

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({
    super.key,
    required this.department,
    required this.cases,
    required this.onView,
    required this.onOpen,
    this.live = false,
  });
  final Department department;
  final bool live;
  final List<AdminCase> cases;
  final VoidCallback onView;
  final ValueChanged<AdminCase> onOpen;

  @override
  Widget build(BuildContext context) {
    int count(ComplaintStatus status) =>
        cases.where((item) => item.status == status).length;
    return StudentPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Label('DEPARTMENT / OVERVIEW'),
          const SizedBox(height: 9),
          const Text(
            'Department dashboard',
            style: TextStyle(
              color: ink,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            department.label,
            style: const TextStyle(color: muted, fontSize: 16),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EDFF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR INBOX',
                      style: TextStyle(
                        color: teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${count(ComplaintStatus.pending)} need your attention',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Review reports and keep students informed.',
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('View complaints'),
                  style: FilledButton.styleFrom(backgroundColor: teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final data = [
                ('Total', cases.length, Icons.grid_view_rounded),
                (
                  'Pending',
                  count(ComplaintStatus.pending),
                  Icons.schedule_outlined,
                ),
                (
                  'In progress',
                  count(ComplaintStatus.inProgress),
                  Icons.pending_actions_outlined,
                ),
                (
                  'Resolved',
                  count(ComplaintStatus.resolved),
                  Icons.task_alt_rounded,
                ),
                (
                  'Rejected',
                  count(ComplaintStatus.rejected),
                  Icons.block_outlined,
                ),
              ];
              final columns = constraints.maxWidth < 550
                  ? 2
                  : constraints.maxWidth < 880
                  ? 3
                  : 5;
              final gap = 10.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final item in data)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.$3, color: teal, size: 22),
                            const SizedBox(height: 8),
                            Text(
                              item.$2.toString(),
                              style: const TextStyle(
                                color: ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              item.$1,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest reports',
                  style: TextStyle(
                    color: ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onView,
                child: const Text('View complaints'),
              ),
            ],
          ),
          const SizedBox(height: 9),
          for (final item in cases.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCaseCard(item: item, onTap: () => onOpen(item)),
            ),
          const SizedBox(height: 13),
          Text(
            live
                ? 'Updates are synchronized with your department.'
                : 'Preview data is temporary. Changes are saved for this session only.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AdminList extends StatelessWidget {
  const AdminList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cases,
    required this.onOpen,
  });
  final String title;
  final String subtitle;
  final List<AdminCase> cases;
  final ValueChanged<AdminCase> onOpen;
  @override
  Widget build(BuildContext context) => StudentPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label('DEPARTMENT / COMPLAINTS'),
        const SizedBox(height: 9),
        Text(
          title,
          style: const TextStyle(
            color: ink,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: muted)),
        const SizedBox(height: 23),
        if (cases.isEmpty)
          const Panel(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No complaints in this view.',
                  style: TextStyle(color: muted),
                ),
              ),
            ),
          )
        else
          for (final item in cases)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCaseCard(item: item, onTap: () => onOpen(item)),
            ),
      ],
    ),
  );
}

class AdminCaseCard extends StatelessWidget {
  const AdminCaseCard({super.key, required this.item, required this.onTap});
  final AdminCase item;
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
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              StatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.details,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 13),
          const Divider(color: border),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.student,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: teal, size: 19),
            ],
          ),
        ],
      ),
    ),
  );
}

class AdminDetail extends StatefulWidget {
  const AdminDetail({
    super.key,
    required this.item,
    required this.onBack,
    required this.onSave,
    this.repository,
  });
  final AdminCase item;
  final VoidCallback onBack;
  final Future<void> Function(ComplaintStatus, String, String) onSave;
  final CampusRepository? repository;
  @override
  State<AdminDetail> createState() => _AdminDetailState();
}

class _AdminDetailState extends State<AdminDetail> {
  late ComplaintStatus status = widget.item.status;
  late final TextEditingController remark = TextEditingController(
    text: widget.item.remark,
  );
  @override
  void dispose() {
    remark.dispose();
    super.dispose();
  }

  bool busy = false;
  String? requestId;
  Future<void> save() async {
    final text = remark.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a remark or a rejection reason before saving.'),
        ),
      );
      return;
    }
    setState(() => busy = true);
    requestId ??= widget.repository?.requestId() ?? 'preview';
    try {
      await widget.onSave(status, text, requestId!);
      requestId = null;
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
        TextButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to complaints'),
        ),
        const SizedBox(height: 9),
        const Label('COMPLAINT / REVIEW'),
        const SizedBox(height: 9),
        Text(
          widget.item.title,
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
                widget.item.id,
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(widget.item.status),
          ],
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student report',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 17),
              Info('Student', widget.item.student),
              Info('Category', widget.item.category.label),
              Info(
                'Submitted',
                '${widget.item.date.day}/${widget.item.date.month}/${widget.item.date.year}',
              ),
              const Divider(color: border),
              const SizedBox(height: 12),
              Text(
                widget.item.details,
                style: const TextStyle(color: ink, height: 1.5),
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
                'Update and respond',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.repository == null
                    ? 'Preview response for the student.'
                    : 'The student will see this status and reply in their account.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const FieldLabel('Complaint status'),
              DropdownButtonFormField<ComplaintStatus>(
                key: const Key('admin_status'),
                initialValue: status,
                items: ComplaintStatus.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => status = value);
                },
              ),
              const SizedBox(height: 16),
              FieldLabel(
                status == ComplaintStatus.rejected
                    ? 'Reason for rejection'
                    : 'Remark to student',
              ),
              TextField(
                key: const Key('admin_remark'),
                controller: remark,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Write a clear update for the student...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: FilledButton.icon(
                  onPressed: busy ? null : save,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(busy ? 'Saving…' : 'Save update'),
                  style: FilledButton.styleFrom(backgroundColor: teal),
                ),
              ),
            ],
          ),
        ),
        if (widget.repository != null) ...[
          const SizedBox(height: 15),
          Panel(
            child: RemarkHistory(
              key: ValueKey(widget.item.id),
              repository: widget.repository!,
              complaintId: widget.item.id,
            ),
          ),
        ] else if (widget.item.remark != null &&
            widget.item.remark!.isNotEmpty) ...[
          const SizedBox(height: 15),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest response',
                  style: TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.item.remark!,
                  style: const TextStyle(color: ink, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}
