
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showChangePasswordDialog(BuildContext context) {
  final oldPassCtrl = TextEditingController();
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
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
              validator: (val) => val!.isEmpty ? "Please enter your old password" : null,
            ),
            TextFormField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Please enter a new password";
                }
                if (val.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            TextFormField(
              controller: confirmPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm New Password"),
              validator: (val) => val != passCtrl.text ? "Passwords do not match" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            final user = FirebaseAuth.instance.currentUser;
            if (user == null || user.email == null) {
              return;
            }
            
            final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassCtrl.text);

            try {
              await user.reauthenticateWithCredential(cred);
              await user.updatePassword(passCtrl.text);
              
              if(context.mounted) {
                Navigator.pop(context);
              }
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password changed successfully")),
                );
              }
            } on FirebaseAuthException catch (e) {
              String errorMessage = "An error occurred. Please try again.";
              if (e.code == 'wrong-password') {
                errorMessage = 'Incorrect old password. Please try again.';
              } else if (e.code == 'weak-password') {
                errorMessage = 'The new password is too weak.';
              } else {
                errorMessage = e.message ?? errorMessage;
              }
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
