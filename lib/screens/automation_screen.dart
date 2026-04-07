import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/fade_animator.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Widget _stepRow(BuildContext context, String number, String text) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
        child: Center(
          child: Text(number, style: TextStyle(color: colors.onPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(width: 12),
      Text(text, style: TextStyle(fontSize: 13, color: colors.onSurface)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: FadeInSlide(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface)),
                    Text('Set rules for your devices', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users/$_uid/rooms').snapshots(),
                builder: (context, roomSnap) {
                  final rooms = roomSnap.data?.docs ?? [];
                  if (rooms.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                                child: Icon(Icons.auto_mode_outlined, size: 48, color: colors.primary),
                              ),
                              const SizedBox(height: 20),
                              Text('No automations yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface)),
                              const SizedBox(height: 8),
                              Text('Add a room and a relay device first to set up automations.',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.5),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isDark ? Border.all(color: Colors.white12) : null,
                                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  children: [
                                    _stepRow(context, '1', 'Go to Rooms tab'), const SizedBox(height: 8),
                                    _stepRow(context, '2', 'Tap Add Room'), const SizedBox(height: 8),
                                    _stepRow(context, '3', 'Tap into room → Add Device'), const SizedBox(height: 8),
                                    _stepRow(context, '4', 'Set type to Relay'), const SizedBox(height: 8),
                                    _stepRow(context, '5', 'Come back here to set rules'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    itemBuilder: (context, i) {
                      final room = rooms[i];
                      return FadeInSlide(
                        delay: Duration(milliseconds: 100 * i),
                        child: _RoomAutomationSection(uid: _uid, roomId: room.id, roomName: room['name'] as String),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomAutomationSection extends StatelessWidget {
  final String uid, roomId, roomName;
  const _RoomAutomationSection({required this.uid, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users/$uid/rooms/$roomId/devices').where('type', isEqualTo: 'relay').snapshots(),
      builder: (context, snap) {
        final devices = snap.data?.docs ?? [];
        if (devices.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(roomName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            ...devices.map((d) => _DeviceAutomationCard(deviceId: d['deviceId'] as String, deviceName: d['name'] as String)),
          ],
        );
      },
    );
  }
}

class _DeviceAutomationCard extends StatelessWidget {
  final String deviceId, deviceName;
  const _DeviceAutomationCard({required this.deviceId, required this.deviceName});

  DatabaseReference get _ref => FirebaseDatabase.instance.ref('devices/$deviceId/automation');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: _ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value as Map? ?? {};
        final autoLight = data['presenceEnabled'] as bool? ?? false;
        final scheduleOn = data['scheduleEnabled'] as bool? ?? false;
        final onTime = data['onTime'] as String? ?? '18:00';
        final offTime = data['offTime'] as String? ?? '23:00';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white12) : null,
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.lightbulb_outline, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(deviceName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colors.onSurface)),
                ]),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _automationTile(
                context: context, icon: Icons.sensors, title: 'Presence detection', subtitle: 'Auto ON when someone is detected',
                value: autoLight, color: colors.primary, onChanged: (val) => _ref.update({'presenceEnabled': val}),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor),
              _automationTile(
                context: context, icon: Icons.schedule, title: 'Time schedule', subtitle: 'Turn ON/OFF at set times',
                value: scheduleOn, color: isDark ? Colors.indigo.shade300 : Colors.indigo, onChanged: (val) => _ref.update({'scheduleEnabled': val}),
              ),
              if (scheduleOn) ...[
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(children: [
                    Expanded(child: _TimePicker(label: 'Turn ON', time: onTime, color: isDark ? Colors.green.shade300 : Colors.green, onPicked: (t) => _ref.update({'onTime': t}), context: context)),
                    const SizedBox(width: 12),
                    Expanded(child: _TimePicker(label: 'Turn OFF', time: offTime, color: isDark ? Colors.red.shade300 : Colors.red, onPicked: (t) => _ref.update({'offTime': t}), context: context)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _DaysSelector(deviceId: deviceId, data: data),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _automationTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required bool value, required Color color, required ValueChanged<bool> onChanged}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(icon, color: value ? color : colors.onSurfaceVariant.withOpacity(0.5), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: colors.onSurface)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ]),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label, time;
  final Color color;
  final ValueChanged<String> onPicked;
  final BuildContext context;

  const _TimePicker({required this.label, required this.time, required this.color, required this.onPicked, required this.context});

  Future<void> _pick() async {
    final parts = time.split(':');
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      onPicked('$h:$m');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(Icons.access_time, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: color)),
              Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            ],
          ),
        ]),
      ),
    );
  }
}

class _DaysSelector extends StatelessWidget {
  final String deviceId;
  final Map data;
  const _DaysSelector({required this.deviceId, required this.data});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  DatabaseReference get _ref => FirebaseDatabase.instance.ref('devices/$deviceId/automation');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final key = _keys[i];
        final selected = data[key] as bool? ?? true;
        return GestureDetector(
          onTap: () => _ref.update({key: !selected}),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? (isDark ? Colors.indigo.shade400 : Colors.indigo) : (isDark ? Colors.white12 : Colors.grey.shade100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_days[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.onSurfaceVariant)),
            ),
          ),
        );
      }),
    );
  }
}