// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:provider/provider.dart';
// import 'firebase_options.dart';
// import 'services/theme_provider.dart';
// import 'widgets/auth_gate.dart';
// import 'theme/app_theme.dart';
//
// final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   if (Firebase.apps.isEmpty) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }
//
//   _initFCM(); // No await — runs in background
//   runApp(const HomeEaseApp());
// }
//
// Future<void> _initFCM() async {
//   try {
//     final messaging = FirebaseMessaging.instance;
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(
//             content: Text(message.notification!.body ?? 'New alert!'),
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     });
//
//     try {
//       final token = await messaging.getToken().timeout(
//         const Duration(seconds: 10),
//         onTimeout: () => null,
//       );
//       if (token != null) {
//         debugPrint("FCM Token: $token");
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) await _saveTokenToFirestore(token);
//       }
//     } catch (e) {
//       debugPrint("FCM token fetch skipped: $e");
//     }
//
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) _saveTokenToFirestore(newToken);
//     });
//   } catch (e) {
//     debugPrint("FCM init skipped: $e");
//   }
// }
//
// Future<void> _saveTokenToFirestore(String? token) async {
//   if (token == null) return;
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//   final tokens = FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .collection('tokens');
//   await tokens.doc(token).set({
//     'token': token,
//     'createdAt': FieldValue.serverTimestamp(),
//     'platform': 'flutter',
//   });
// }
//
// class HomeEaseApp extends StatelessWidget {
//   const HomeEaseApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: Consumer<ThemeProvider>(
//         builder: (context, provider, child) {
//           return MaterialApp(
//             scaffoldMessengerKey: scaffoldMessengerKey,
//             title: 'HomeEase',
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.light,
//             darkTheme: AppTheme.dark,
//             themeMode: provider.themeMode,
//             home: const AuthGate(),
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/theme_provider.dart';
import 'widgets/auth_gate.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const HomeEaseApp());
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