import 'package:flutter/material.dart';
import '../../models/admin_case.dart';
import '../../models/complaint.dart';
import '../../theme/colors.dart';
import '../../widgets/student_widgets.dart';
import '../auth_screen.dart';
import '../../services/campus_repository.dart';
import '../../widgets/remark_history.dart';
import 'department_accounts_screen.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key, this.repository, this.liveItems});
  final CampusRepository? repository;
  final List<AdminCase>? liveItems;
  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final demoCases = demoAdminCases();
  List<AdminCase> get cases => widget.liveItems ?? demoCases;
  Category? category;
  Department? department;
  ComplaintStatus? status;
  int tab = 0;
  int filterVersion = 0;

  List<AdminCase> get filtered {
    return cases
        .where(
          (item) =>
              (category == null || item.category == category) &&
              (department == null || item.department == department) &&
              (status == null || item.status == status),
        )
        .toList();
  }

  void exitPreview() {
    if (widget.repository != null) {
      widget.repository!.auth.signOut();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Container(
                width: 220,
                color: ink,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Brand(light: true),
                    const SizedBox(height: 38),
                    const Text(
                      'CAMPUS OVERSIGHT',
                      style: TextStyle(
                        color: Color(0xFF9FB1CF),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _nav(Icons.space_dashboard_outlined, 'Overview', 0),
                    _nav(Icons.view_list_outlined, 'All complaints', 1),
                    if (widget.repository != null)
                      _nav(Icons.manage_accounts_outlined, 'Administrators', 2),
                    const Spacer(),
                    const Text(
                      'SUPER ADMIN',
                      style: TextStyle(
                        color: Color(0xFF9FB1CF),
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: exitPreview,
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        widget.repository == null
                            ? 'Leave preview'
                            : 'Sign out',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 32 : 16,
                        vertical: wide ? 26 : 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CAMPUSCONNECT  /  SUPER ADMIN',
                                      style: TextStyle(
                                        color: teal,
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tab == 0
                                          ? 'Campus overview'
                                          : tab == 1
                                          ? 'All complaints'
                                          : 'Administrator accounts',
                                      style: const TextStyle(
                                        color: ink,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -.7,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tab == 0
                                          ? 'A clear view of every department.'
                                          : tab == 1
                                          ? 'Find and review reports across campus.'
                                          : 'Assign access to the responsible department.',
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!wide)
                                IconButton(
                                  onPressed: exitPreview,
                                  tooltip: widget.repository == null
                                      ? 'Leave preview'
                                      : 'Sign out',
                                  icon: const Icon(Icons.logout),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (tab == 0) ...[
                            _overview(),
                            const SizedBox(height: 20),
                            _sectionTitle(
                              'Recent complaints',
                              'View all',
                              () => setState(() => tab = 1),
                            ),
                            const SizedBox(height: 8),
                            _caseList(cases.take(4).toList()),
                          ] else if (tab == 2 && widget.repository != null) ...[
                            DepartmentAccountsScreen(
                              repository: widget.repository!,
                            ),
                          ] else ...[
                            _filters(),
                            const SizedBox(height: 16),
                            _sectionTitle(
                              '${filtered.length} complaints',
                              'Clear filters',
                              () => setState(() {
                                category = null;
                                department = null;
                                status = null;
                                filterVersion++;
                              }),
                            ),
                            const SizedBox(height: 8),
                            _caseList(filtered),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            widget.repository == null
                                ? 'Preview data is temporary.'
                                : 'Showing saved campus records.',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (value) => setState(() => tab = value),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_list_outlined),
                  label: 'Complaints',
                ),
                if (widget.repository != null)
                  const NavigationDestination(
                    icon: Icon(Icons.manage_accounts_outlined),
                    label: 'Admins',
                  ),
              ],
            ),
    );
  }

  Widget _nav(IconData icon, String title, int value) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Material(
      color: tab == value ? const Color(0xFF35598F) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white, size: 19),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        onTap: () => setState(() => tab = value),
      ),
    ),
  );

  Widget _overview() {
    final counts = <(String, int, Color)>[
      ('All reports', cases.length, teal),
      for (final s in ComplaintStatus.values)
        (s.label, cases.where((c) => c.status == s).length, s.color),
    ];
    final maxCount = Department.values
        .map((c) => cases.where((x) => x.department == c).length)
        .fold<int>(1, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 480
                ? 2
                : constraints.maxWidth < 800
                ? 3
                : 5;
            final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in counts)
                  SizedBox(
                    width: width,
                    child: _box(
                      Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: item.$3,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.$2}',
                              style: const TextStyle(
                                color: ink,
                                fontSize: 23,
                                height: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _box(
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complaints by department',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Total reports across all statuses',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                for (final c in Department.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final count = cases
                            .where((x) => x.department == c)
                            .length;
                        return Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth < 380 ? 80 : 130,
                              child: Text(
                                c.label,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: count / maxCount,
                                  minHeight: 9,
                                  backgroundColor: mist,
                                  color: teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$count',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filters() => _box(
    Padding(
      key: ValueKey(filterVersion),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 600
              ? constraints.maxWidth
              : (constraints.maxWidth - 16) / 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<Category>(
                      key: const Key('super_category'),
                      initialValue: category,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Category',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All categories'),
                        ),
                        for (final c in Category.values)
                          DropdownMenuItem(value: c, child: Text(c.label)),
                      ],
                      onChanged: (value) => setState(() => category = value),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<Department>(
                      key: const Key('super_department'),
                      initialValue: department,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Department',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All departments'),
                        ),
                        for (final c in Department.values)
                          DropdownMenuItem(
                            value: c,
                            child: Text(
                              c.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => department = value),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<ComplaintStatus>(
                      key: const Key('super_status'),
                      initialValue: status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Status',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All statuses'),
                        ),
                        for (final s in ComplaintStatus.values)
                          DropdownMenuItem(value: s, child: Text(s.label)),
                      ],
                      onChanged: (value) => setState(() => status = value),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _sectionTitle(String title, String action, VoidCallback onTap) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );

  Widget _caseList(List<AdminCase> items) => _box(
    items.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No complaints match these filters.',
                style: TextStyle(color: muted),
              ),
            ),
          )
        : Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: border),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  onTap: () => _showDetails(items[i]),
                  title: Text(
                    items[i].title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${items[i].id}  ·  ${items[i].category.label}  ·  ${items[i].student}',
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                  trailing: StatusBadge(items[i].status),
                ),
              ],
            ],
          ),
  );

  void _showDetails(AdminCase item) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(item.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Info('Reference', item.id),
            Info('Student', item.student),
            Info('Category', item.category.label),
            Info('Department', item.department.label),
            Info('Status', item.status.label),
            const Divider(),
            const SizedBox(height: 8),
            Text(item.details),
            if (widget.repository != null) ...[
              const SizedBox(height: 16),
              RemarkHistory(
                repository: widget.repository!,
                complaintId: item.id,
              ),
            ] else if (item.remark != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Department response',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(item.remark!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Widget _box(Widget child) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
