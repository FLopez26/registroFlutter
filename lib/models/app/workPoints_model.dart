import 'package:cloud_firestore/cloud_firestore.dart';

class WorkPoint {
  final String name;
  final double latitude;
  final double longitude;
  String? id; // ID generado automáticamente por Firestore

  WorkPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.id, // El ID es opcional, porque lo asignará Firestore
  });

  // Convertir el objeto WorkPoint a un mapa (para enviar a Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Crear un objeto WorkPoint a partir de un mapa (cuando se recibe desde Firebase)
  factory WorkPoint.fromMap(Map<String, dynamic> map) {
    return WorkPoint(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  // Método para guardar el WorkPoint en Firestore
  Future<void> save(String userId, String companyId) async {
    final workPointRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId)
        .collection('workPoints')
        .doc(); // Firestore genera un ID automáticamente
    this.id = workPointRef.id; // Asignamos el ID generado por Firestore
    await workPointRef.set(toMap());
  }

  // Método para obtener un WorkPoint desde Firestore
  static Future<WorkPoint?> getWorkPoint(String userId, String companyId, String workPointId) async {
    final workPointRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId)
        .collection('workPoints')
        .doc(workPointId);
    final docSnapshot = await workPointRef.get();

    if (docSnapshot.exists) {
      return WorkPoint.fromMap(docSnapshot.data()!);
    }
    return null; // Si el WorkPoint no existe
  }
}