import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/theme_provider.dart';
import 'widgets/auth_gate.dart';
import 'theme/app_theme.dart';

// Create a global key for the ScaffoldMessenger
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initFCM();
  runApp(const HomeEaseApp());
}

Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message.notification!.body ?? 'New message!'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  });


  final token = await messaging.getToken();
  print("FCM Token: $token"); // For debugging

  // Save the token to Firestore
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await _saveTokenToFirestore(token);
  }

  // Listen for token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    if (user != null) {
      _saveTokenToFirestore(newToken);
    }
  });
}

Future<void> _saveTokenToFirestore(String? token) async {
  if (token == null) return;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final tokens = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tokens');
  await tokens.doc(token).set({
    'token': token,
    'createdAt': FieldValue.serverTimestamp(),
    'platform': 'flutter',
  });
}


class HomeEaseApp extends StatelessWidget {
  const HomeEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey, // Add this line
            title: 'HomeEase',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: provider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
