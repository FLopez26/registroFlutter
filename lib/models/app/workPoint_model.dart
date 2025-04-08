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

  // Método para guardar el WorkPoint en Firestore
  Future<void> save(String userId, String companyId) async {
    final wpRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId)
        .collection('workPoints')
        .doc(); // Generamos un nuevo ID
    id = wpRef.id;
    await wpRef.set(toMap()); // Guardamos el WorkPoint en Firestore
  }

  // Método para obtener un WorkPoint desde Firestore usando su ID
  static Future<WorkPoint?> getWorkPoint(String userId, String companyId, String workPointId) async {
    final wpRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId)
        .collection('workPoints')
        .doc(workPointId);

    final docSnapshot = await wpRef.get();

    if (docSnapshot.exists) {
      return WorkPoint.fromMap(docSnapshot.data()!);
    }
    return null; // Si no existe el WorkPoint
  }
}
