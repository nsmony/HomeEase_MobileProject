import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeease/services/auth_service.dart';

void showEditProfileDialog(BuildContext context) {
  final nameCtrl = TextEditingController(text: FirebaseAuth.instance.currentUser?.displayName);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Profile"),
      content: TextField(
        controller: nameCtrl,
        decoration: const InputDecoration(labelText: "Full Name"),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (nameCtrl.text.trim().isEmpty) return;
            try {
              await AuthService().updateProfile(name: nameCtrl.text.trim());
              Navigator.pop(context);
            } catch (e) {
              // Handle error
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
