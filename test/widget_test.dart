//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:homeease/main.dart';
//
// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
//
//   setUpAll(() async {
//     // Mock Firebase Core
//     TestDefaultBinaryMessenger.instance.setMockMethodCallHandler(
//       const MethodChannel('plugins.flutter.io/firebase_core'),
//       (MethodCall methodCall) async {
//         if (methodCall.method == 'Firebase#initializeCore') {
//           return [
//             {
//               'name': '[DEFAULT]',
//               'options': {
//                 'apiKey': 'test',
//                 'appId': 'test',
//                 'messagingSenderId': 'test',
//                 'projectId': 'test',
//               },
//               'pluginConstants': {},
//             }
//           ];
//         }
//         return null;
//       },
//     );
//
//     // Mock Firebase Auth
//     TestDefaultBinaryMessenger.instance.setMockMethodCallHandler(
//       const MethodChannel('plugins.flutter.io/firebase_auth'),
//       (MethodCall methodCall) async {
//         return null;
//       },
//     );
//
//     await Firebase.initializeApp(
//         options: const FirebaseOptions(
//             apiKey: 'test',
//             appId: 'test',
//             messagingSenderId: 'test',
//             projectId: 'test'));
//   });
//
//   tearDownAll(() {
//     TestDefaultBinaryMessenger.instance.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/firebase_core'), null);
//     TestDefaultBinaryMessenger.instance.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/firebase_auth'), null);
//   });
//
//
//   testWidgets('Renders LoginScreen when not logged in', (WidgetTester tester) async {
//     await tester.pumpWidget(const HomeEaseApp());
//     await tester.pumpAndSettle();
//
//     expect(find.text('Welcome Back!'), findsOneWidget);
//   });
// }
