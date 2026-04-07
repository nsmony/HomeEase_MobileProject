import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/fade_animator.dart';

class DevicesScreen extends StatelessWidget {
  final String roomId;
  final String roomName;
  const DevicesScreen({super.key, required this.roomId, required this.roomName});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference get _devices => FirebaseFirestore.instance.collection('users/$_uid/rooms/$roomId/devices');

  BoxDecoration _cardDecoration(BuildContext context, {Color? customColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: customColor ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: isDark ? Border.all(color: Colors.white12) : null,
      boxShadow: isDark ? [] : [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  Future<void> _addDevice(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final deviceIdCtrl = TextEditingController();
    String selectedType = 'relay';
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a device', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: TextStyle(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Device name',
                  prefixIcon: Icon(Icons.devices_outlined, color: colors.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: isDark ? colors.surface : Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deviceIdCtrl,
                style: TextStyle(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Device ID (e.g. ESP32-A1B2)',
                  prefixIcon: Icon(Icons.qr_code, color: colors.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: isDark ? colors.surface : Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _typeChip(context, 'Relay', 'relay', selectedType, Icons.toggle_on_outlined, (v) => setState(() => selectedType = v)),
                  const SizedBox(width: 8),
                  _typeChip(context, 'Sensor', 'sensor', selectedType, Icons.sensors, (v) => setState(() => selectedType = v)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final deviceId = deviceIdCtrl.text.trim();
                    if (name.isEmpty || deviceId.isEmpty) return;
                    await _devices.add({
                      'name': name,
                      'type': selectedType,
                      'deviceId': deviceId,
                      'addedAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Device', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, String label, String value, String selected, IconData icon, Function(String) onTap) {
    final isSelected = value == selected;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer : (isDark ? colors.surface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? colors.primary.withOpacity(0.5) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? colors.primary : colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? (isDark ? Colors.white : colors.primary) : colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(roomName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _addDevice(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _devices.orderBy('addedAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_outlined, size: 64, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 12),
                  Text('No devices yet', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('Tap Add to connect a device', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant.withOpacity(0.6))),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final name = doc['name'] as String;
              final type = doc['type'] as String;
              final deviceId = doc['deviceId'] as String;

              Widget card = type == 'relay'
                  ? RelayCard(name: name, deviceId: deviceId, decoration: _cardDecoration(context))
                  : SensorCard(name: name, deviceId: deviceId, decorationBuilder: _cardDecoration);

              return FadeInSlide(delay: Duration(milliseconds: 100 * i), child: card);
            },
          );
        },
      ),
    );
  }
}

class RelayCard extends StatelessWidget {
  final String name;
  final String deviceId;
  final BoxDecoration decoration;

  const RelayCard({super.key, required this.name, required this.deviceId, required this.decoration});

  DatabaseReference get _ref => FirebaseDatabase.instance.ref('devices/$deviceId/relay');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: _ref.onValue,
      builder: (context, snapshot) {
        final isOn = snapshot.data?.snapshot.value as bool? ?? false;

        // Dynamic decoration to highlight when ON
        final activeDecoration = decoration.copyWith(
          color: isOn ? (isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50) : decoration.color,
          border: Border.all(color: isOn ? (isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade200) : (isDark ? Colors.white12 : Colors.transparent)),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: activeDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOn ? (isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade100) : (isDark ? Colors.white12 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lightbulb_outline, color: isOn ? Colors.amber.shade600 : Colors.grey, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colors.onSurface)),
                    Text(isOn ? 'Turned ON' : 'Turned OFF', style: TextStyle(fontSize: 12, color: isOn ? Colors.amber.shade700 : colors.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(value: isOn, onChanged: (val) => _ref.set(val), activeColor: colors.primary),
            ],
          ),
        );
      },
    );
  }
}

class SensorCard extends StatelessWidget {
  final String name;
  final String deviceId;
  final BoxDecoration Function(BuildContext, {Color? customColor}) decorationBuilder;

  const SensorCard({super.key, required this.name, required this.deviceId, required this.decorationBuilder});

  DatabaseReference get _ref => FirebaseDatabase.instance.ref('devices/$deviceId');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: _ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value as Map? ?? {};
        final temp = data['temperature']?.toString() ?? '--';
        final humidity = data['humidity']?.toString() ?? '--';
        final gas = data['gas'] as String? ?? 'unknown';
        final isDanger = gas == 'danger';

        final activeDecoration = decorationBuilder(context, customColor: isDanger ? (isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50) : null).copyWith(
          border: isDanger ? Border.all(color: isDark ? Colors.red.shade800 : Colors.red.shade200) : null,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: activeDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDanger ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade100) : (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.sensors, color: isDanger ? Colors.red.shade500 : Colors.blue.shade500, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colors.onSurface)),
                  const Spacer(),
                  if (isDanger)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
                      child: Text('GAS DANGER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stat(context, Icons.thermostat, '$temp°C', 'Temperature', isDark ? Colors.orange.shade300 : Colors.orange),
                  _divider(context),
                  _stat(context, Icons.water_drop_outlined, '$humidity%', 'Humidity', isDark ? Colors.blue.shade300 : Colors.blue),
                  _divider(context),
                  _stat(context, isDanger ? Icons.warning_amber_rounded : Icons.check_circle_outline, isDanger ? 'Danger' : 'Safe', 'Gas', isDanger ? (isDark ? Colors.red.shade300 : Colors.red) : (isDark ? Colors.green.shade300 : Colors.green)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(BuildContext context, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(width: 1, height: 40, color: Theme.of(context).dividerColor);
}