class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.departmentId,
  });
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? departmentId;
  factory UserProfile.fromMap(String id, Map<String, dynamic> data) =>
      UserProfile(
        id: id,
        fullName: data['full_name'] as String,
        email: data['email'] as String,
        role: data['role'] as String,
        departmentId: data['department_id'] as String?,
      );
}
