import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _changePassword() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      /// 🔥 Re-authenticate (IMPORTANT)
      final cred = EmailAuthProvider.credential(
        email: email!,
        password: currentPassCtrl.text.trim(),
      );

      await user!.reauthenticateWithCredential(cred);

      /// 🔥 Update password
      await user.updatePassword(newPassCtrl.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: currentPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}