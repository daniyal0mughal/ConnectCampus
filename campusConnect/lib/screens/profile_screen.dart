import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/student_widgets.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onExit, this.profile});
  final UserProfile? profile;
  final VoidCallback onExit;
  @override
  Widget build(BuildContext context) => StudentPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label('STUDENT ACCOUNT'),
        const SizedBox(height: 8),
        const Heading('My profile', 'Your student account.'),
        const SizedBox(height: 22),
        Panel(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: mist,
                radius: 26,
                child: Icon(Icons.person_outline, color: teal),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.fullName ?? 'Student preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      profile?.email ?? 'Demo account · no sign-in required',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onExit,
          icon: const Icon(Icons.logout_rounded),
          label: Text(profile == null ? 'Leave preview' : 'Sign out'),
        ),
      ],
    ),
  );
}
