import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum Category { cafeteria, library, labs, academic }

enum Department { cs, medical }

extension DepartmentInfo on Department {
  String get label => switch (this) {
    Department.cs => 'CS Department',
    Department.medical => 'Medical Department',
  };
}

Category categoryFromDocumentId(String id) =>
    Category.values.byName(id.split('_').last);

extension CategoryInfo on Category {
  String get label => switch (this) {
    Category.cafeteria => 'Cafeteria',
    Category.library => 'Library',
    Category.labs => 'Labs & IT',
    Category.academic => 'Academic affairs',
  };
  String documentId(Department department) => '${department.name}_$name';
  IconData get icon => switch (this) {
    Category.cafeteria => Icons.restaurant_outlined,
    Category.library => Icons.local_library_outlined,
    Category.labs => Icons.computer_outlined,
    Category.academic => Icons.school_outlined,
  };
}

enum ComplaintStatus { pending, inProgress, resolved, rejected }

extension StatusInfo on ComplaintStatus {
  String get databaseValue =>
      this == ComplaintStatus.inProgress ? 'In Progress' : label;
  String get label => switch (this) {
    ComplaintStatus.pending => 'Pending',
    ComplaintStatus.inProgress => 'In progress',
    ComplaintStatus.resolved => 'Resolved',
    ComplaintStatus.rejected => 'Rejected',
  };
  Color get color => switch (this) {
    ComplaintStatus.pending => const Color(0xFF9B651C),
    ComplaintStatus.inProgress => teal,
    ComplaintStatus.resolved => const Color(0xFF287451),
    ComplaintStatus.rejected => const Color(0xFFBD5747),
  };
  Color get background => switch (this) {
    ComplaintStatus.pending => const Color(0xFFFFF0D5),
    ComplaintStatus.inProgress => mist,
    ComplaintStatus.resolved => const Color(0xFFE5F3E8),
    ComplaintStatus.rejected => const Color(0xFFFFE9E5),
  };
}

class Complaint {
  Complaint(
    this.id,
    this.title,
    this.details,
    this.category,
    this.status,
    this.date, [
    this.response,
    this.department = Department.cs,
  ]);
  final String id;
  final String title;
  final String details;
  final Category category;
  final Department department;
  final ComplaintStatus status;
  final DateTime date;
  final String? response;
}
