import 'complaint.dart';

class AdminCase {
  AdminCase({
    required this.id,
    required this.student,
    required this.title,
    required this.details,
    required this.category,
    required this.department,
    required this.status,
    required this.date,
    this.remark,
  });
  final String id;
  final String student;
  final String title;
  final String details;
  final Category category;
  final Department department;
  ComplaintStatus status;
  final DateTime date;
  String? remark;
}

List<AdminCase> demoAdminCases() => [
  AdminCase(
    id: 'CC-1048',
    student: 'Ayesha Khan',
    title: 'Study room lights are broken',
    details:
        'Three ceiling lights in the north study room are not working. It is difficult to read after 4 PM.',
    category: Category.library,
    department: Department.cs,
    status: ComplaintStatus.pending,
    date: DateTime(2026, 11, 19),
  ),
  AdminCase(
    id: 'CC-1041',
    student: 'Bilal Ahmed',
    title: 'Updated reference books needed',
    details:
        'The current software engineering references are several editions old.',
    category: Category.library,
    department: Department.cs,
    status: ComplaintStatus.inProgress,
    date: DateTime(2026, 11, 17),
    remark: 'The acquisition list has been shared with the faculty committee.',
  ),
  AdminCase(
    id: 'CC-1029',
    student: 'Sara Ali',
    title: 'Extend library hours during exams',
    details: 'Students need the reading hall open later during exam weeks.',
    category: Category.library,
    department: Department.medical,
    status: ComplaintStatus.resolved,
    date: DateTime(2026, 11, 12),
    remark: 'The reading hall will remain open until 9 PM during exam week.',
  ),
  AdminCase(
    id: 'CC-1047',
    student: 'Hamza Noor',
    title: 'Food served cold at lunch',
    details: 'Lunch was cold at the main cafeteria counter today.',
    category: Category.cafeteria,
    department: Department.cs,
    status: ComplaintStatus.pending,
    date: DateTime(2026, 11, 19),
  ),
  AdminCase(
    id: 'CC-1031',
    student: 'Zara Malik',
    title: 'More vegetarian options',
    details: 'Please offer an affordable vegetarian meal each day.',
    category: Category.cafeteria,
    department: Department.medical,
    status: ComplaintStatus.resolved,
    date: DateTime(2026, 11, 13),
    remark: 'A new daily vegetarian meal has been added.',
  ),
  AdminCase(
    id: 'CC-1046',
    student: 'Usman Tariq',
    title: 'Wi-Fi disconnects in Lab 2',
    details: 'The connection drops every few minutes in Lab 2.',
    category: Category.labs,
    department: Department.cs,
    status: ComplaintStatus.inProgress,
    date: DateTime(2026, 11, 18),
    remark: 'The access point is being inspected.',
  ),
  AdminCase(
    id: 'CC-1036',
    student: 'Hira Shah',
    title: 'Projector does not display',
    details: 'The projector in Computer Lab 1 is not working.',
    category: Category.labs,
    department: Department.medical,
    status: ComplaintStatus.rejected,
    date: DateTime(2026, 11, 15),
    remark:
        'This equipment belongs to Classroom 1. Please submit under Academic affairs.',
  ),
  AdminCase(
    id: 'CC-1045',
    student: 'Mariam Raza',
    title: 'Lecture notes not available',
    details: 'The latest lecture notes have not yet been uploaded.',
    category: Category.academic,
    department: Department.cs,
    status: ComplaintStatus.pending,
    date: DateTime(2026, 11, 18),
  ),
  AdminCase(
    id: 'CC-1033',
    student: 'Daniyal Abbas',
    title: 'Class starts late',
    details: 'Our Monday class has started more than 20 minutes late twice.',
    category: Category.academic,
    department: Department.medical,
    status: ComplaintStatus.inProgress,
    date: DateTime(2026, 11, 14),
    remark: 'The timetable coordinator is reviewing the schedule.',
  ),
];
