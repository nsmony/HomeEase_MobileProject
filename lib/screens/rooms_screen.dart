import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'devices_screen.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference get _rooms =>
      FirebaseFirestore.instance.collection('users/$_uid/rooms');

  // Room icon mapping
  IconData _roomIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('living')) return Icons.weekend_outlined;
    if (n.contains('bed')) return Icons.bed_outlined;
    if (n.contains('kitchen')) return Icons.kitchen_outlined;
    if (n.contains('bath')) return Icons.bathtub_outlined;
    if (n.contains('garage')) return Icons.garage_outlined;
    if (n.contains('office')) return Icons.computer_outlined;
    return Icons.meeting_room_outlined;
  }

  Future<void> _addRoom(BuildContext context) async {
    final nameCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add a room',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Living Room, Bedroom',
                prefixIcon: const Icon(Icons.meeting_room_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  await _rooms.add({
                    'name': name,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Room',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Rooms',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () => _addRoom(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rooms list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _rooms.orderBy('createdAt').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_outlined,
                              size: 64,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No rooms yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          Text('Tap Add Room to get started',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400)),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final name = doc['name'] as String;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DevicesScreen(
                              roomId: doc.id,
                              roomName: name,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                            Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Icon(_roomIcon(name),
                                    color: Colors.teal.shade600,
                                    size: 24),
                              ),
                              const Spacer(),
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('Tap to manage',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
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