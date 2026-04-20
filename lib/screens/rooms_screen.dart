import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'devices_screen.dart';
import '../widgets/fade_animator.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference get _rooms =>
      FirebaseFirestore.instance.collection('users/$_uid/rooms');

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
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a room',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Living Room, Bedroom',
                prefixIcon: Icon(Icons.meeting_room_outlined,
                    color: colors.onSurfaceVariant),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? colors.surface : Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(ctx);
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  await _rooms.add({
                    'name': name,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Room',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String docId, String roomName) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Room'),
        content: Text(
            'Are you sure you want to delete "$roomName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(
                    color: colors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _rooms.doc(docId).delete();
    }
  }

  Future<void> _editRoom(
      BuildContext context, String docId, String currentName) async {
    final nameCtrl = TextEditingController(text: currentName);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rename Room',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Room name',
                prefixIcon: Icon(Icons.meeting_room_outlined,
                    color: colors.onSurfaceVariant),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? colors.surface : Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(ctx);
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  await _rooms.doc(docId).update({'name': name});
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FadeInSlide(
                    child: Text('My Rooms',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface)),
                  ),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: ElevatedButton.icon(
                      onPressed: () => _addRoom(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Room'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _rooms.orderBy('createdAt').snapshots(),
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
                          Icon(Icons.meeting_room_outlined,
                              size: 64,
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No rooms yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: colors.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('Tap Add Room to get started',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant
                                      .withAlpha(153))),
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
                      childAspectRatio: 1.0,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final name = doc['name'] as String;

                      return FadeInSlide(
                        delay: Duration(milliseconds: 100 + (i * 50)),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DevicesScreen(
                                  roomId: doc.id, roomName: name),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: isDark
                                  ? Border.all(color: Colors.white12)
                                  : null,
                              boxShadow: isDark
                                  ? []
                                  : [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: Icon(_roomIcon(name),
                                          color: colors.primary, size: 22),
                                    ),
                                    const Spacer(),
                                    // Edit button
                                    GestureDetector(
                                      onTap: () => _editRoom(
                                          context, doc.id, name),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: colors.primaryContainer,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.edit_outlined,
                                            color: colors.primary, size: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Delete button
                                    GestureDetector(
                                      onTap: () => _confirmDelete(
                                          context, doc.id, name),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: colors.errorContainer,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.delete_outline,
                                            color: colors.error, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: colors.onSurface),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('Tap to manage',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: colors.onSurfaceVariant)),
                              ],
                            ),
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