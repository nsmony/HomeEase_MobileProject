import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good ${_greeting()}! 👋',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications_outlined,
                        color: Colors.teal.shade700),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Summary cards
              Row(
                children: [
                  _summaryCard('Active Devices', '—', Icons.devices,
                      Colors.teal),
                  const SizedBox(width: 12),
                  _summaryCard('Rooms', '—', Icons.meeting_room_outlined,
                      Colors.indigo),
                ],
              ),

              const SizedBox(height: 24),

              // Environment section
              Text('Environment',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800)),
              const SizedBox(height: 12),
              _EnvironmentCard(),

              const SizedBox(height: 24),

              // Quick tip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick tip',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('Go to Rooms to add your first device.',
                              style: TextStyle(
                                  color: Colors.teal.shade100,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _summaryCard(
      String label, String value, IconData icon, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color.shade600, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace 'ESP32-A1B2' with your actual device ID later
    final ref = FirebaseDatabase.instance.ref('devices/ESP32-A1B2');

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final data =
            snapshot.data?.snapshot.value as Map? ?? {};
        final temp = data['temperature']?.toString() ?? '--';
        final humidity = data['humidity']?.toString() ?? '--';
        final gas = data['gas'] as String? ?? 'unknown';
        final isDanger = gas == 'danger';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              _envTile(Icons.thermostat, '$temp°C', 'Temp',
                  Colors.orange),
              _divider(),
              _envTile(Icons.water_drop_outlined, '$humidity%',
                  'Humidity', Colors.blue),
              _divider(),
              _envTile(
                isDanger
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                isDanger ? 'Danger' : 'Safe',
                'Gas',
                isDanger ? Colors.red : Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _envTile(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style:
              TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 50, color: Colors.grey.shade100);
  }
}