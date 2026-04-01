import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DevicesScreen extends StatelessWidget {
  final String roomId;
  final String roomName;
  const DevicesScreen(
      {super.key, required this.roomId, required this.roomName});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference get _devices => FirebaseFirestore.instance
      .collection('users/$_uid/rooms/$roomId/devices');

  Future<void> _addDevice(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final deviceIdCtrl = TextEditingController();
    String selectedType = 'relay';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              const Text('Add a device',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Device name',
                  prefixIcon: const Icon(Icons.devices_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deviceIdCtrl,
                decoration: InputDecoration(
                  labelText: 'Device ID (e.g. ESP32-A1B2)',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 12),
              // Type selector
              Row(
                children: [
                  _typeChip('Relay', 'relay', selectedType,
                      Icons.toggle_on_outlined, (v) {
                        setState(() => selectedType = v);
                      }),
                  const SizedBox(width: 8),
                  _typeChip('Sensor', 'sensor', selectedType,
                      Icons.sensors, (v) {
                        setState(() => selectedType = v);
                      }),
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
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Device',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value, String selected,
      IconData icon, Function(String) onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
          isSelected ? Colors.teal.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.teal.shade400
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? Colors.teal.shade600
                    : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.teal.shade700
                        : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(roomName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _addDevice(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
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
                  Icon(Icons.devices_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No devices yet',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Tap Add to connect a device',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final name = doc['name'] as String;
              final type = doc['type'] as String;
              final deviceId = doc['deviceId'] as String;
              if (type == 'relay') {
                return RelayCard(name: name, deviceId: deviceId);
              } else {
                return SensorCard(name: name, deviceId: deviceId);
              }
            },
          );
        },
      ),
    );
  }
}

// ── Relay Card ──────────────────────────────────────────────────
class RelayCard extends StatelessWidget {
  final String name;
  final String deviceId;
  const RelayCard(
      {super.key, required this.name, required this.deviceId});

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('devices/$deviceId/relay');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _ref.onValue,
      builder: (context, snapshot) {
        final isOn =
            snapshot.data?.snapshot.value as bool? ?? false;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOn
                  ? Colors.amber.shade200
                  : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOn
                      ? Colors.amber.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: isOn ? Colors.amber.shade600 : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(
                      isOn ? 'Turned ON' : 'Turned OFF',
                      style: TextStyle(
                          fontSize: 12,
                          color: isOn
                              ? Colors.amber.shade700
                              : Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: (val) => _ref.set(val),
                activeColor: Colors.teal,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sensor Card ─────────────────────────────────────────────────
class SensorCard extends StatelessWidget {
  final String name;
  final String deviceId;
  const SensorCard(
      {super.key, required this.name, required this.deviceId});

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('devices/$deviceId');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _ref.onValue,
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
            border: Border.all(
              color: isDanger
                  ? Colors.red.shade200
                  : Colors.grey.shade100,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDanger
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.sensors,
                        color: isDanger
                            ? Colors.red.shade600
                            : Colors.blue.shade600,
                        size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const Spacer(),
                  if (isDanger)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('GAS DANGER',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stat(Icons.thermostat, '$temp°C', 'Temperature',
                      Colors.orange),
                  _divider(),
                  _stat(Icons.water_drop_outlined, '$humidity%',
                      'Humidity', Colors.blue),
                  _divider(),
                  _stat(
                    isDanger
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    isDanger ? 'Danger' : 'Safe',
                    'Gas',
                    isDanger ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade100);
}