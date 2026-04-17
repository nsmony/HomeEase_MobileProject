
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/fade_animator.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

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
                    Text('Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface)),
                    Text('Configure sensor thresholds', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No devices yet', style: TextStyle(color: colors.onSurfaceVariant)),
                        ],
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
                        child: _RoomAlertSection(uid: _uid, roomId: room.id, roomName: room['name'] as String),
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

class _RoomAlertSection extends StatelessWidget {
  final String uid, roomId, roomName;
  const _RoomAlertSection({required this.uid, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users/$uid/rooms/$roomId/devices').where('type', isEqualTo: 'sensor').snapshots(),
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
            ...devices.map((d) => _DeviceAlertCard(deviceId: d['deviceId'] as String, deviceName: d['name'] as String)),
          ],
        );
      },
    );
  }
}

class _DeviceAlertCard extends StatelessWidget {
  final String deviceId, deviceName;
  const _DeviceAlertCard({required this.deviceId, required this.deviceName});

  DatabaseReference get _ref => FirebaseDatabase.instance.ref('devices/$deviceId/alerts');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: _ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value as Map? ?? {};
        final gasOn = data['gasEnabled'] as bool? ?? true;
        final humOn = data['humidityEnabled'] as bool? ?? true;
        final tempOn = data['tempEnabled'] as bool? ?? true;
        final gasVal = (data['gasThreshold'] as num?)?.toDouble() ?? 50;
        final humVal = (data['humThreshold'] as num?)?.toDouble() ?? 70;
        final tempVal = (data['tempThreshold'] as num?)?.toDouble() ?? 35;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white12) : null,
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.sensors, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(deviceName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colors.onSurface)),
                ]),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _AlertThresholdTile(
                context: context, icon: Icons.gas_meter_outlined, title: 'Gas alert', subtitle: 'Notify when gas > ${gasVal.toInt()}%',
                color: isDark ? Colors.red.shade300 : Colors.red, enabled: gasOn, value: gasVal, min: 10, max: 100, unit: '%',
                onToggle: (v) => _ref.update({'gasEnabled': v}), onSlide: (v) => _ref.update({'gasThreshold': v}),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor),
              _AlertThresholdTile(
                context: context, icon: Icons.water_drop_outlined, title: 'Humidity alert', subtitle: 'Notify when humidity > ${humVal.toInt()}%',
                color: isDark ? Colors.blue.shade300 : Colors.blue, enabled: humOn, value: humVal, min: 30, max: 100, unit: '%',
                onToggle: (v) => _ref.update({'humidityEnabled': v}), onSlide: (v) => _ref.update({'humThreshold': v}),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor),
              _AlertThresholdTile(
                context: context, icon: Icons.thermostat, title: 'Temperature alert', subtitle: 'Notify when temp > ${tempVal.toInt()}°C',
                color: isDark ? Colors.orange.shade300 : Colors.orange, enabled: tempOn, value: tempVal, min: 20, max: 60, unit: '°C',
                onToggle: (v) => _ref.update({'tempEnabled': v}), onSlide: (v) => _ref.update({'tempThreshold': v}),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _AlertThresholdTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title, subtitle, unit;
  final Color color;
  final bool enabled;
  final double value, min, max;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onSlide;

  const _AlertThresholdTile({
    required this.context, required this.icon, required this.title, required this.subtitle, required this.color,
    required this.enabled, required this.value, required this.min, required this.max, required this.unit,
    required this.onToggle, required this.onSlide,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(children: [
            Icon(icon, color: enabled ? color : colors.onSurfaceVariant.withAlpha(128), size: 20),
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
            Switch(value: enabled, onChanged: onToggle, activeThumbColor: color),
          ]),
          if (enabled) ...[
            const SizedBox(height: 4),
            Row(children: [
              Text('${min.toInt()}$unit', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color, thumbColor: color, overlayColor: color.withAlpha(26),
                    inactiveTrackColor: color.withAlpha(51), trackHeight: 3,
                  ),
                  child: Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), onChanged: onSlide),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                child: Text('${value.toInt()}$unit', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
