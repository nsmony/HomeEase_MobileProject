import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Updates display name in Firebase Auth + Firestore.
  /// Profile photo is stored as base64 in Firestore (no Storage needed).
  Future<void> updateProfile({String? name, String? photoBase64}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final Map<String, dynamic> firestoreUpdates = {};

    if (name != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
      firestoreUpdates['name'] = name;
    }

    if (photoBase64 != null) {
      firestoreUpdates['photoBase64'] = photoBase64;
    }

    if (firestoreUpdates.isNotEmpty) {
      await _db.collection('users').doc(user.uid).update(firestoreUpdates);
    }

    await user.reload();
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}