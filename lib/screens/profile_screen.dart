import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/theme_provider.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/fade_animator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storageService = StorageService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;
    final initials =
        name.isNotEmpty ? name.trim().split(' ').map((e) => e[0]).take(2).join() : 'U';

    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              FadeInSlide(
                child: GestureDetector(
                  onTap: () async {
                    final uid = user?.uid;
                    if (uid == null) return;
                    final photoUrl = await _storageService.uploadProfilePicture(uid);
                    if (photoUrl != null) {
                      await _authService.updateProfile(photoUrl: photoUrl);
                      setState(() {});
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colors.primaryContainer,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(initials.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  children: [
                    Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface)),
                    Text(email, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info cards
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    _infoTile(context, Icons.person_outline, 'Full Name', name),
                    const SizedBox(height: 12),
                    _infoTile(context, Icons.email_outlined, 'Email', email),
                    const SizedBox(height: 12),
                    _buildThemeSwitcher(context, themeProvider, isDark, colors),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),

              // Action buttons
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    _actionButton(context, "Edit Profile", Icons.edit_outlined, () async {
                      await showEditProfileDialog(context);
                      setState(() {});
                    }),
                    const SizedBox(height: 12),
                    _actionButton(context, "Change Password", Icons.lock_outline, () => showChangePasswordDialog(context)),
                  ],
                ),
              ),


              const SizedBox(height: 24),

              // Logout
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => AuthService().logout(),
                    icon: Icon(Icons.logout, color: isDark ? Colors.red.shade300 : Colors.red),
                    label: Text('Sign Out', style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.red.shade800 : Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  Widget _actionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.5)
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 24),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
          ],
        ),
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
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitcher(
      BuildContext context, ThemeProvider provider, bool isDark, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: isDark ? [] : [ BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)) ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.brightness_6_outlined, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          const Text('Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const Spacer(),
          DropdownButton<ThemeMode>(
            value: provider.themeMode,
            onChanged: (mode) {
              if (mode != null) provider.setThemeMode(mode);
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
