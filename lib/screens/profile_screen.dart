import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../widgets/fade_animator.dart';
import 'package:homeease/theme/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 500,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);

      if (base64String.length > 1000000) {
        throw Exception("Image is too large. Please pick a smaller one.");
      }

      await _firestore.collection('users').doc(user.uid).update({
        'photoBase64': base64String,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _showEditNameDialog(String currentName) async {
    final TextEditingController _nameController = TextEditingController(text: currentName);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: "Enter your name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.trim().isNotEmpty) {
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({'name': _nameController.text.trim()});
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: Text("No user"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'User';
          final email = data?['email'] ?? user.email ?? '';

          final photoBase64 = data?['photoBase64'];

          final initials = name.isNotEmpty
              ? name.trim().split(' ').map((e) => e[0]).take(2).join()
              : 'U';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  FadeInSlide(
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.surface, width: 3),
                            ),
                            child: ClipOval(
                              child: photoBase64 != null
                                  ? Image.memory(
                                base64Decode(photoBase64),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      initials.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: colors.primary,
                                      ),
                                    ),
                                  );
                                },
                              )
                                  : Center(
                                child: Text(
                                  initials.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isUploading)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.surface, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: colors.onPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- NAME SECTION ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showEditNameDialog(name),
                          borderRadius: BorderRadius.circular(20),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- INFO TILES ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        _infoTile(context, Icons.person_outline, 'Full Name', name),
                        const SizedBox(height: 12),
                        _infoTile(context, Icons.email_outlined, 'Email', email),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- THEME SWITCHER ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 250),
                    child: SwitchListTile(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (bool value) {
                        themeManager.toggleTheme(value);
                      },
                      title: const Text('Dark Mode'),
                      secondary: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- LOGOUT BUTTON ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => AuthService().logout(),
                        icon: Icon(Icons.logout,
                            color: isDark ? Colors.red.shade300 : Colors.red),
                        label: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: isDark ? Colors.red.shade300 : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.red.shade800
                                : Colors.red.shade200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(
      BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                    TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}