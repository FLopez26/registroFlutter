import 'package:cloud_firestore/cloud_firestore.dart';

import 'company_model.dart';

class Admin {
  final String email;
  final String password;
  List<Company> companies; // Lista de objetos Company
  String? id; // ID generado automáticamente por Firestore

  Admin({
    required this.email,
    required this.password,
    required this.companies,
    this.id, // El ID es opcional, porque lo asignará Firestore
  });

  // Convertir el objeto Admin a un mapa (para enviar a Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'companies': companies.map((company) => company.toMap()).toList(),
    };
  }

  // Crear un objeto Admin a partir de un mapa (cuando se recibe desde Firebase)
  factory Admin.fromMap(Map<String, dynamic> map, String documentId) {
    return Admin(
      id: documentId, // El ID de Firestore será pasado aquí
      email: map['email'],
      password: map['password'],
      companies: (map['companies'] as List)
          .map((companyMap) => Company.fromMap(companyMap))
          .toList(),
    );
  }

  // Método para guardar el administrador en Firestore
  Future<void> save() async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(); // Firestore genera un ID automáticamente
    this.id = adminRef.id; // Asignamos el ID generado por Firestore a la propiedad `id`
    await adminRef.set(toMap());
  }

  // Método para obtener un administrador desde Firestore
  static Future<Admin?> getAdmin(String documentId) async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(documentId);
    final docSnapshot = await adminRef.get();

    if (docSnapshot.exists) {
      return Admin.fromMap(docSnapshot.data()!, docSnapshot.id); // Le pasamos el ID del documento
    }
    return null; // Si el administrador no existe
  }
}