
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/fade_animator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('HomeEase', style: TextStyle(color: colors.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colors.onSurfaceVariant),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Center(
        child: FadeInSlide(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.waving_hand_outlined, size: 48, color: colors.primary),
              ),
              const SizedBox(height: 24),
              Text('Welcome, ${user?.displayName ?? 'User'}!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface)),
              const SizedBox(height: 8),
              Text(user?.email ?? 'N/A',
                  style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
