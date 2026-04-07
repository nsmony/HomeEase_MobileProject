import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'theme/app_theme.dart'; // <-- 1. Import your new theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HomeEaseApp());
}

class HomeEaseApp extends StatelessWidget {
  const HomeEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeEase',
      debugShowCheckedModeBanner: false,

      // 2. Replace the old ThemeData with your custom AppTheme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // <-- Automatically switches based on device settings

      home: const AuthGate(),
    );
  }
}