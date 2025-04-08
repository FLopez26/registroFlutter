import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichajes/models/app/workPoint_model.dart';

class Company {
  final String name;
  final List<WorkPoint> workPoints;
  String? id;

  Company({
    required this.name,
    required this.workPoints,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workPoints': workPoints.map((workPoint) => workPoint.toMap()).toList(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map, String documentId) {
    return Company(
      id: documentId,
      name: map['name'],
      workPoints: [],
    );
  }

  // Método para guardar la compañía en Firestore
  Future<void> save(String userId) async {
    final companyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('companies')
        .doc();
    this.id = companyRef.id;
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
      return Company.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null; // Si la compañía no existe
  }

  //TODO eliminar
}