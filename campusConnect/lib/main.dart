import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/session_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const preview = bool.fromEnvironment('ENABLE_PREVIEW', defaultValue: false);
  if (!preview) {
    try {
      await Firebase.initializeApp(options: campusFirebaseOptions);
    } catch (_) {
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Unable to connect to Firebase. Please reload and try again.',
              ),
            ),
          ),
        ),
      );
      return;
    }
  }
  runApp(const CampusConnectApp(preview: preview));
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key, this.preview = false});
  final bool preview;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CampusConnect',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: teal, surface: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
      ),
    ),
    home: preview ? const AuthScreen() : const SessionGate(),
  );
}
