import 'package:cloud_firestore/cloud_firestore.dart';

const incidentCategories = [
  'Water',
  'Electricity',
  'Facilities',
  'Furniture',
  'Sanitation',
  'Safety',
  'Other',
];

const incidentStatuses = ['Submitted', 'In Review', 'In Progress', 'Resolved'];

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String reporterId;
  final String reporterEmail;
  final String? imageUrl;
  final DateTime createdAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterEmail,
    required this.createdAt,
    this.imageUrl,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return Incident(
      id: doc.id,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      category: m['category'] ?? 'Other',
      location: m['location'] ?? '',
      status: m['status'] ?? 'Submitted',
      reporterId: m['reporterId'] ?? '',
      reporterEmail: m['reporterEmail'] ?? '',
      imageUrl: m['imageUrl'],
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'status': status,
        'reporterId': reporterId,
        'reporterEmail': reporterEmail,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
