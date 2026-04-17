// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:homeease/screens/change_password.dart';
// import '../services/auth_service.dart';
// import '../widgets/fade_animator.dart';
// import '../screens/edit_profile.dart';
// import '../screens/change_password.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.userChanges(),
//           builder: (context, snapshot) {
//             final user = snapshot.data;
//
//             final name = user?.displayName ?? 'User';
//             final email = user?.email ?? '';
//             final photoUrl = user?.photoURL;
//
//             final initials = name.isNotEmpty
//                 ? name.trim().split(' ').map((e) => e[0]).take(2).join()
//                 : 'U';
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//
//                   ///  Avatar
//                   FadeInSlide(
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundColor: colors.primaryContainer,
//                       backgroundImage: photoUrl != null
//                           ? NetworkImage(
//                               '$photoUrl?v=${DateTime.now().millisecondsSinceEpoch}',
//                             )
//                           : null,
//                       child: photoUrl == null
//                           ? Text(
//                               initials.toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: colors.primary,
//                               ),
//                             )
//                           : null,
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   /// Name + Email
//                   FadeInSlide(
//                     delay: const Duration(milliseconds: 100),
//                     child: Column(
//                       children: [
//                         Text(
//                           name,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: colors.onSurface,
//                           ),
//                         ),
//                         Text(
//                           email,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: colors.onSurfaceVariant,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//
//                         /// Edit Profile Button
//                         ElevatedButton.icon(
//                           onPressed: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const EditProfileScreen(),
//                               ),
//                             );
//
//                             // Force refresh from Firebase
//                             await FirebaseAuth.instance.currentUser?.reload();
//                           },
//                           icon: const Icon(Icons.edit),
//                           label: const Text("Edit Profile"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: colors.primary,
//                             foregroundColor: colors.onPrimary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   /// 🔥 Account Info
//                   FadeInSlide(
//                     delay: const Duration(milliseconds: 200),
//                     child: Column(
//                       children: [
//                         _infoTile(
//                           context,
//                           Icons.person_outline,
//                           'Full Name',
//                           name,
//                         ),
//                         const SizedBox(height: 12),
//                         _infoTile(
//                           context,
//                           Icons.email_outlined,
//                           'Email',
//                           email,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 34),
//
//                   /// 🔥 Security
//                   FadeInSlide(
//                     delay: const Duration(milliseconds: 250),
//                     child: _actionTile(
//                       context,
//                       Icons.lock_outline,
//                       'Change Password',
//                       () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const ChangePasswordScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   /// 🔥 Logout
//                   FadeInSlide(
//                     delay: const Duration(milliseconds: 300),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: OutlinedButton.icon(
//                         onPressed: () => AuthService().logout(),
//                         icon: Icon(
//                           Icons.logout,
//                           color: isDark ? Colors.red.shade300 : Colors.red,
//                         ),
//                         label: Text(
//                           'Sign Out',
//                           style: TextStyle(
//                             color: isDark ? Colors.red.shade300 : Colors.red,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(
//                             color: isDark
//                                 ? Colors.red.shade800
//                                 : Colors.red.shade200,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   ///  Info Tile
//   Widget _infoTile(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String value,
//   ) {
//     final colors = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: isDark ? Border.all(color: Colors.white12) : null,
//         boxShadow: isDark
//             ? []
//             : [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: colors.primaryContainer,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: colors.primary, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: colors.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔹 Action Tile
//   Widget _actionTile(
//     BuildContext context,
//     IconData icon,
//     String title,
//     VoidCallback onTap,
//   ) {
//     final colors = Theme.of(context).colorScheme;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: colors.primaryContainer,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: colors.primary, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: colors.onSurface,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: colors.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeease/screens/change_password.dart';
import '../services/auth_service.dart';
import '../widgets/fade_animator.dart';
import '../screens/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final name = data?['name'] ?? user?.displayName ?? 'User';
            final email = data?['email'] ?? user?.email ?? '';
            final base64Str = data?['photoBase64'] ?? '';

            final initials = name.isNotEmpty
                ? name.trim().split(' ').map((e) => e[0]).take(2).join()
                : 'U';

            // 🔥 Build image from Base64
            ImageProvider? imageProvider;
            if (base64Str.isNotEmpty) {
              try {
                imageProvider = MemoryImage(base64Decode(base64Str));
              } catch (e) {
                imageProvider = null;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// 🔥 Avatar
                  FadeInSlide(
                    child: CircleAvatar(
                      radius: 40,
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
                  ),

                  const SizedBox(height: 12),

                  /// 🔥 Name + Email + Edit Button
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Edit Profile Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🔥 Account Info
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

                  const SizedBox(height: 32),

                  /// 🔥 Change Password
                  FadeInSlide(
                    delay: const Duration(milliseconds: 250),
                    child: _actionTile(
                      context,
                      Icons.lock_outline,
                      'Change Password',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🔥 Logout
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => AuthService().logout(),
                        icon: Icon(
                          Icons.logout,
                          color: isDark ? Colors.red.shade300 : Colors.red,
                        ),
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

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoTile(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}