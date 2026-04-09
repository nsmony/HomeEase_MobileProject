import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/fade_animator.dart'; // Make sure to import the animator!

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInSlide(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good ${_greeting()}! 👋',
                            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),

                        // ✅ FIX: Added StreamBuilder to fetch name from Firestore
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
                          builder: (context, snapshot) {
                            String displayName = 'User';
                            if (snapshot.hasData && snapshot.data!.data() != null) {
                              final data = snapshot.data!.data() as Map<String, dynamic>;
                              displayName = data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'User';
                            }

                            return Text(
                              displayName,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications_outlined, color: colors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Room + device count cards
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    _RoomCountCard(uid: _uid),
                    const SizedBox(width: 12),
                    _DeviceCountCard(uid: _uid),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Environment
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Environment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface)),
                    const SizedBox(height: 12),
                    const _EnvironmentCard(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Presence status
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Presence',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface)),
                    const SizedBox(height: 12),
                    const _PresenceCard(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Active alerts
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Alerts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface)),
                    const SizedBox(height: 12),
                    const _ActiveAlertsCard(),
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
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ── Shared Card Decoration helper ──────────────────────────────
BoxDecoration _cardDecoration(BuildContext context, {Color? customColor}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: customColor ?? Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: isDark ? Border.all(color: Colors.white12) : null,
    boxShadow: isDark ? [] : [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

// ── Room count ───────────────────────────────────────────────
class _RoomCountCard extends StatelessWidget {
  final String uid;
  const _RoomCountCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/rooms').snapshots(),
        builder: (context, snap) {
          final count = snap.data?.docs.length ?? 0;
          return _statCard(context, 'Rooms', count.toString(), Icons.meeting_room_outlined, Colors.indigo);
        },
      ),
    );
  }
}

// ── Device count ─────────────────────────────────────────────
class _DeviceCountCard extends StatelessWidget {
  final String uid;
  const _DeviceCountCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/rooms').snapshots(),
        builder: (context, roomSnap) {
          final rooms = roomSnap.data?.docs ?? [];
          if (rooms.isEmpty) return _statCard(context, 'Devices', '0', Icons.devices, Colors.teal);

          return StreamBuilder<List<QuerySnapshot>>(
            stream: Stream.fromFuture(Future.wait(
              rooms.map((r) => FirebaseFirestore.instance.collection('users/$uid/rooms/${r.id}/devices').get()),
            )),
            builder: (context, devSnap) {
              final total = devSnap.data?.fold<int>(0, (sum, qs) => sum + qs.docs.length) ?? 0;
              return _statCard(context, 'Devices', total.toString(), Icons.devices, Colors.teal);
            },
          );
        },
      ),
    );
  }
}

Widget _statCard(BuildContext context, String label, String value, IconData icon, MaterialColor color) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? color.withOpacity(0.2) : color.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDark ? color.shade200 : color.shade600, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    ),
  );
}

// ── Environment card ─────────────────────────────────────────
class _EnvironmentCard extends StatelessWidget {
  const _EnvironmentCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('devices/HSE-00001');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value as Map? ?? {};
        final temp = data['temperature']?.toString() ?? '--';
        final humidity = data['humidity']?.toString() ?? '--';
        final gas = data['gas'] as String? ?? 'unknown';
        final isDanger = gas == 'danger';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(context, customColor: isDanger ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50) : null),
          child: Row(
            children: [
              _envTile(context, Icons.thermostat, '$temp°C', 'Temp', isDark ? Colors.orange.shade300 : Colors.orange),
              _vDivider(context),
              _envTile(context, Icons.water_drop_outlined, '$humidity%', 'Humidity', isDark ? Colors.blue.shade300 : Colors.blue),
              _vDivider(context),
              _envTile(
                context,
                isDanger ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                isDanger ? 'Danger' : 'Safe',
                'Gas',
                isDanger ? (isDark ? Colors.red.shade300 : Colors.red) : (isDark ? Colors.green.shade300 : Colors.green),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _envTile(BuildContext context, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }

  Widget _vDivider(BuildContext context) =>
      Container(width: 1, height: 50, color: Theme.of(context).dividerColor);
}

// ── Presence card ─────────────────────────────────────────────
class _PresenceCard extends StatelessWidget {
  const _PresenceCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('devices/HSE-00001/presence');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final present = snapshot.data?.snapshot.value as bool? ?? false;

        Color bgColor = Theme.of(context).colorScheme.surface;
        if (present) bgColor = isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.shade50;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(context, customColor: bgColor),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: present ? (isDark ? Colors.teal.withOpacity(0.3) : Colors.teal.shade100) : Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  present ? Icons.person : Icons.person_off_outlined,
                  color: present ? (isDark ? Colors.tealAccent : Colors.teal.shade700) : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(present ? 'Someone is home' : 'Nobody home',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: present ? (isDark ? Colors.tealAccent : Colors.teal.shade700) : Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text(present ? 'Presence detected by sensor' : 'No presence detected',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              const Spacer(),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: present ? Colors.teal : Theme.of(context).dividerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Active alerts card ────────────────────────────────────────
class _ActiveAlertsCard extends StatelessWidget {
  const _ActiveAlertsCard();

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('devices/HSE-00001');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value as Map? ?? {};
        final gas = data['gas'] as String? ?? 'safe';
        final temp = (data['temperature'] as num?)?.toDouble() ?? 0;
        final humidity = (data['humidity'] as num?)?.toDouble() ?? 0;

        final alerts = <Map<String, dynamic>>[];
        if (gas == 'danger') {
          alerts.add({'icon': Icons.warning_amber_rounded, 'msg': 'Gas level is dangerous!', 'color': Colors.red});
        }
        if (temp > 35) {
          alerts.add({'icon': Icons.thermostat, 'msg': 'Temperature above 35°C', 'color': Colors.orange});
        }
        if (humidity > 80) {
          alerts.add({'icon': Icons.water_drop, 'msg': 'Humidity above 80%', 'color': Colors.blue});
        }

        if (alerts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(context, customColor: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50),
            child: Row(children: [
              Icon(Icons.check_circle_outline, color: isDark ? Colors.greenAccent : Colors.green.shade600),
              const SizedBox(width: 12),
              Text('All systems normal',
                  style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade700, fontWeight: FontWeight.w500)),
            ]),
          );
        }

        return Column(
          children: alerts.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (a['color'] as Color).withOpacity(isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (a['color'] as Color).withOpacity(isDark ? 0.5 : 0.3)),
            ),
            child: Row(children: [
              Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
              const SizedBox(width: 10),
              Text(a['msg'] as String,
                  style: TextStyle(color: a['color'] as Color, fontWeight: FontWeight.w500)),
            ]),
          )).toList(),
        );
      },
    );
  }
}