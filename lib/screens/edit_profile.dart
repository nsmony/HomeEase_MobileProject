// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//
//   File? _image;
//   final picker = ImagePicker();
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final user = FirebaseAuth.instance.currentUser;
//     nameController.text = user?.displayName ?? '';
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }
//
//   /// SAVE PROFILE
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     final user = FirebaseAuth.instance.currentUser;
//     final oldPhotoUrl = user?.photoURL;
//
//     try {
//       String? imageUrl;
//
//       // Upload new image if selected
//       if (_image != null) {
//         imageUrl = await _uploadImage(_image!);
//       }
//
//       // Update display name
//       await user?.updateDisplayName(nameController.text.trim());
//
//       // Update photo URL
//       if (imageUrl != null) {
//         // Evict old image from cache
//         if (oldPhotoUrl != null) {
//           await NetworkImage(oldPhotoUrl).evict();
//         }
//         // Also evict the new URL in case it was cached before
//         await NetworkImage(imageUrl).evict();
//
//         await user?.updatePhotoURL(imageUrl);
//       }
//
//       // Reload user to get fresh data
//       await user?.reload();
//
//       if (!mounted) return;
//
//       setState(() => _isLoading = false);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//
//       setState(() => _isLoading = false);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   /// PICK IMAGE
//   Future<void> _pickImage() async {
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (ctx) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 12),
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const SizedBox(height: 12),
//           ListTile(
//             leading: const Icon(Icons.photo_camera),
//             title: const Text('Take a photo'),
//             onTap: () => Navigator.pop(ctx, ImageSource.camera),
//           ),
//           ListTile(
//             leading: const Icon(Icons.photo_library),
//             title: const Text('Choose from gallery'),
//             onTap: () => Navigator.pop(ctx, ImageSource.gallery),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//
//     if (source == null) return;
//
//     final pickedFile = await picker.pickImage(
//       source: source,
//       maxWidth: 500,
//       maxHeight: 500,
//       imageQuality: 80,
//     );
//
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   /// UPLOAD IMAGE to Firebase Storage
//   Future<String?> _uploadImage(File imageFile) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('profile_pictures')
//           .child('${user!.uid}.jpg');
//
//       await ref.putFile(imageFile);
//
//       // Add cache-busting timestamp to the URL
//       final downloadUrl = await ref.getDownloadURL();
//       return '$downloadUrl&v=${DateTime.now().millisecondsSinceEpoch}';
//     } catch (e) {
//       debugPrint('Upload error: $e');
//       return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final photoUrl = user?.photoURL;
//     final colors = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Profile")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               /// AVATAR
//               GestureDetector(
//                 onTap: _isLoading ? null : _pickImage,
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: colors.primaryContainer,
//                       backgroundImage: _image != null
//                           ? FileImage(_image!) as ImageProvider
//                           : (photoUrl != null
//                           ? NetworkImage(photoUrl)
//                           : null),
//                       child: _image == null && photoUrl == null
//                           ? Icon(
//                         Icons.camera_alt,
//                         size: 30,
//                         color: colors.primary,
//                       )
//                           : null,
//                     ),
//                     // Edit badge
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: colors.primary,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: Icon(
//                           Icons.edit,
//                           size: 14,
//                           color: colors.onPrimary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//               Text(
//                 'Tap to change photo',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: colors.onSurfaceVariant,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               /// NAME FIELD
//               TextFormField(
//                 controller: nameController,
//                 enabled: !_isLoading,
//                 decoration: const InputDecoration(
//                   labelText: "Full Name",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person_outline),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 24),
//
//               /// SAVE BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colors.primary,
//                     foregroundColor: colors.onPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                       color: Colors.white,
//                     ),
//                   )
//                       : const Text(
//                     "Save Changes",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  File? _image;
  String? _base64Image; // 🔥 stores image as text
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? '';
    _loadExistingImage();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /// 🔥 LOAD existing Base64 image from Firestore
  Future<void> _loadExistingImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['photoBase64'] != null) {
      setState(() {
        _base64Image = doc.data()!['photoBase64'];
      });
    }
  }

  /// 🔥 SAVE PROFILE
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    try {
      // Convert image to Base64 if new image selected
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        _base64Image = base64Encode(bytes);
      }

      // Update display name in Firebase Auth
      await user?.updateDisplayName(nameController.text.trim());
      await user?.reload();

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': user.email,
        'photoBase64': _base64Image ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully ✅')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// 🔥 PICK IMAGE
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 300,   // 🔥 Keep small for Firestore limit
      maxHeight: 300,
      imageQuality: 50, // 🔥 Compress heavily
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// 🔥 Build avatar — shows picked image, base64, or initials
  Widget _buildAvatar() {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'U';
    final initials = name.trim().split(' ').map((e) => e[0]).take(2).join();

    ImageProvider? imageProvider;

    if (_image != null) {
      // New image picked — show file
      imageProvider = FileImage(_image!);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      // Existing base64 from Firestore
      imageProvider = MemoryImage(base64Decode(_base64Image!));
    }

    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colors.primaryContainer,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
              initials.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.edit, size: 14, color: colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// AVATAR
              _buildAvatar(),

              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 24),

              /// NAME FIELD
              TextFormField(
                controller: nameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}