import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/rooms_screen.dart';
import '../screens/automation_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RoomsScreen(),
    AutomationScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          indicatorColor: colors.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: colors.onSurfaceVariant),
              selectedIcon: Icon(Icons.dashboard, color: colors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined, color: colors.onSurfaceVariant),
              selectedIcon: Icon(Icons.meeting_room, color: colors.primary),
              label: 'Rooms',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_mode_outlined, color: colors.onSurfaceVariant),
              selectedIcon: Icon(Icons.auto_mode, color: colors.primary),
              label: 'Auto',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined, color: colors.onSurfaceVariant),
              selectedIcon: Icon(Icons.notifications, color: colors.primary),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: colors.onSurfaceVariant),
              selectedIcon: Icon(Icons.person, color: colors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
