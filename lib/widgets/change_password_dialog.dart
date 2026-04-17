import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showChangePasswordDialog(BuildContext context) {
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Change Password"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
              validator: (val) => val!.isEmpty ? "Please enter a password" : null,
            ),
            TextFormField(
              controller: confirmPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              validator: (val) => val != passCtrl.text ? "Passwords do not match" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            try {
              await FirebaseAuth.instance.currentUser?.updatePassword(passCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password changed successfully")),
              );
            } on FirebaseAuthException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? "An error occurred")),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
