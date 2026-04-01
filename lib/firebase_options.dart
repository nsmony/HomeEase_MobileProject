import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGyxooz2ddHBb2Znt-3aI8VTKn1-Vt920',
    appId: '1:107616380311:android:48e93d9d001e6a5db350d2',
    messagingSenderId: '107616380311',
    projectId: 'homeease-16dfd',
    storageBucket: 'homeease-16dfd.firebasestorage.app',
  );
}