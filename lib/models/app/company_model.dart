import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichajes/models/app/workPoint_model.dart';

class Company {
  final String name;
  final List<WorkPoint> workPoints; // Lista de objetos WorkPoint
  String? id; // ID generado automáticamente por Firestore

  Company({
    required this.name,
    required this.workPoints,
    this.id, // El ID es opcional, porque lo asignará Firestore
  });

  // Convertir el objeto Company a un mapa (para enviar a Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workPoints': workPoints.map((workPoint) => workPoint.toMap()).toList(),
    };
  }

  // Crear un objeto Company a partir de un mapa (cuando se recibe desde Firebase)
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      name: map['name'],
      workPoints: (map['workPoints'] as List)
          .map((workPointMap) => WorkPoint.fromMap(workPointMap))
          .toList(),
    );
  }

  // Método para guardar la compañía en Firestore
  Future<void> save(String userId) async {
    final companyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(); // Firestore genera un ID automáticamente
    this.id = companyRef.id; // Asignamos el ID generado por Firestore
    await companyRef.set(toMap());
  }

  // Método para obtener una compañía desde Firestore
  static Future<Company?> getCompany(String userId, String companyId) async {
    final companyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc(companyId);
    final docSnapshot = await companyRef.get();

    if (docSnapshot.exists) {
      return Company.fromMap(docSnapshot.data()!);
    }
    return null; // Si la compañía no existe
  }
}