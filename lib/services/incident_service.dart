import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/incident.dart';

class IncidentService {
  final _col = FirebaseFirestore.instance.collection('incidents');
  final _storage = FirebaseStorage.instance;

  Stream<List<Incident>> stream() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Incident.fromDoc).toList());

  Future<void> create(Incident incident, File? image) async {
    final doc = _col.doc();
    String? url;

    if (image != null) {
      final ref = _storage.ref(
        'incident_images/${incident.reporterId}/${doc.id}.jpg',
      );
      await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
      url = await ref.getDownloadURL();
    }

    final data = incident.toMap()..['imageUrl'] = url;
    await doc.set(data);
  }

  Future<void> updateStatus(String id, String status) => _col.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) async {
    final doc = await _col.doc(id).get();
    final imageUrl = doc.data()?['imageUrl'] as String?;
    await _col.doc(id).delete();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {
        // The report is already deleted; a missing photo should not block it.
      }
    }
  }
}
