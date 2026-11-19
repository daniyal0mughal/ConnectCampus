import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/complaint.dart';
import '../widgets/student_widgets.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import 'complaints_screen.dart';
import 'new_complaint_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import '../models/user_profile.dart';
import '../services/campus_repository.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({
    super.key,
    this.repository,
    this.profile,
    this.liveItems,
  });
  final CampusRepository? repository;
  final UserProfile? profile;
  final List<Complaint>? liveItems;
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int tab = 0;
  Complaint? open;
  ComplaintStatus? filter;
  List<Complaint> get complaints => widget.liveItems ?? demoComplaints;
  final demoComplaints = <Complaint>[
    Complaint(
      'CC-1042',
      'Wi-Fi keeps disconnecting in Lab 2',
      'The internet connection drops repeatedly during lab sessions.',
      Category.labs,
      ComplaintStatus.inProgress,
      DateTime(2026, 11, 18),
      'Our IT team is checking the access point in Lab 2.',
    ),
    Complaint(
      'CC-1038',
      'More study seats needed',
      'The library reading room is full most afternoons.',
      Category.library,
      ComplaintStatus.pending,
      DateTime(2026, 11, 16),
    ),
    Complaint(
      'CC-1024',
      'Cafeteria menu options',
      'Please add more affordable vegetarian lunch options.',
      Category.cafeteria,
      ComplaintStatus.resolved,
      DateTime(2026, 11, 10),
      'Two new vegetarian options have been added to the weekly menu.',
    ),
  ];
  void go(int value) => setState(() {
    tab = value;
    open = null;
  });
  String? pendingRequest;
  Future<void> submit(
    Department department,
    Category category,
    String title,
    String details,
  ) async {
    if (widget.repository != null) {
      pendingRequest ??= widget.repository!.requestId();
      await widget.repository!.createComplaint(
        department,
        category,
        title,
        details,
        pendingRequest!,
      );
      pendingRequest = null;
      if (mounted) {
        setState(() {
          tab = 1;
          open = null;
        });
      }
      return;
    }
    final item = Complaint(
      'CC-${1043 + complaints.length - 3}',
      title,
      details,
      category,
      ComplaintStatus.pending,
      DateTime.now(),
      null,
      department,
    );
    setState(() {
      complaints.insert(0, item);
      open = item;
      tab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (open != null && widget.liveItems != null) {
      final current = complaints.where((i) => i.id == open!.id);
      open = current.isEmpty ? null : current.first;
    }
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = open != null
        ? DetailScreen(
            item: open!,
            repository: widget.repository,
            onBack: () => setState(() => open = null),
          )
        : switch (tab) {
            0 => Dashboard(
              items: complaints,
              onNew: () => go(2),
              onAll: () => go(1),
            ),
            1 => ComplaintsScreen(
              items: complaints,
              filter: filter,
              onFilter: (value) => setState(() => filter = value),
              onOpen: (item) => setState(() => open = item),
              onNew: () => go(2),
            ),
            2 => NewComplaintScreen(
              onSubmit: submit,
              live: widget.repository != null,
            ),
            _ => ProfileScreen(
              profile: widget.profile,
              onExit: widget.repository != null
                  ? () {
                      widget.repository!.auth.signOut();
                    }
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuthScreen(),
                      ),
                    ),
            ),
          };
    return Scaffold(
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  Container(
                    width: 240,
                    color: Colors.white,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Brand(),
                        const SizedBox(height: 42),
                        SideLink(
                          Icons.grid_view_rounded,
                          'Dashboard',
                          tab == 0 && open == null,
                          () => go(0),
                        ),
                        SideLink(
                          Icons.article_outlined,
                          'My complaints',
                          tab == 1 && open == null,
                          () => go(1),
                        ),
                        SideLink(
                          Icons.add_circle_outline,
                          'New complaint',
                          tab == 2 && open == null,
                          () => go(2),
                        ),
                        const Spacer(),
                        const Divider(color: border),
                        SideLink(
                          Icons.person_outline,
                          'My profile',
                          tab == 3 && open == null,
                          () => go(3),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, color: border),
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
                  icon: Icon(Icons.grid_view_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.article_outlined),
                  label: 'Complaints',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'New',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
