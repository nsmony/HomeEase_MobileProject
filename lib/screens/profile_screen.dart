import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/fade_animator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name.trim().split(' ').map((e) => e[0]).take(2).join() : 'U';

    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                  child: Center(
                    child: Text(initials.toUpperCase(),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary)),
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
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => AuthService().logout(),
                    icon: Icon(Icons.logout, color: isDark ? Colors.red.shade300 : Colors.red),
                    label: Text('Sign Out', style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.red.shade800 : Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)),
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
}