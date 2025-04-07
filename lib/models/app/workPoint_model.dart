import 'package:cloud_firestore/cloud_firestore.dart';

class WorkPoint {
  String? id;
  final String name;
  final double latitude;
  final double longitude;

  WorkPoint({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory WorkPoint.fromMap(Map<String, dynamic> map) {
    return WorkPoint(
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<void> save(String userId, String companyId) async {
    final wpRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId)
        .collection('workPoints')
        .doc();
    id = wpRef.id;
    await wpRef.set(toMap());
  }
}