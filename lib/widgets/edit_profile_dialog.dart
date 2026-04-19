import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

Future<void> showEditProfileDialog(BuildContext context) {
  final nameCtrl = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName);

  return showDialog(
    context: context,
    builder: (context) {
      bool loading = false;
      String? error;

      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  setState(() => error = 'Name cannot be empty');
                  return;
                }
                setState(() {
                  loading = true;
                  error = null;
                });
                try {
                  await AuthService().updateProfile(name: name);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    loading = false;
                    error = 'Failed to update. Try again.';
                  });
                }
              },
              child: loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}