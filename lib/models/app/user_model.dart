import 'package:cloud_firestore/cloud_firestore.dart';

import 'company_model.dart';

class User {
  final String email;
  final String password;
  bool working; // True trabajando, false no
  List<Company> companies; // Lista de objetos Company
  String? id; // ID generado automáticamente por Firestore

  User({
    required this.email,
    required this.password,
    this.working = false, // Valor por defecto
    required this.companies,
    this.id, // El ID es opcional, porque lo asignará Firestore
  });

  // Convertir el objeto User a un mapa (para enviar a Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'working': working,
      'companies': companies.map((company) => company.toMap()).toList(),
    };
  }

  // Crear un objeto User a partir de un mapa (cuando se recibe desde Firebase)
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId, // El ID de Firestore será pasado aquí
      email: map['email'],
      password: map['password'],
      working: map['working'] ?? false,  // Valor por defecto si no está en el mapa
      companies: (map['companies'] as List)
          .map((companyMap) => Company.fromMap(companyMap))
          .toList(),
    );
  }

  // Método para guardar el usuario en Firestore
  Future<void> save() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(); // Firestore genera un ID automáticamente
    this.id = userRef.id; // Asignamos el ID generado por Firestore a la propiedad `id`
    await userRef.set(toMap());
  }

  // Método para obtener un usuario desde Firestore
  static Future<User?> getUser(String documentId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(documentId);
    final docSnapshot = await userRef.get();

    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data()!, docSnapshot.id); // Le pasamos el ID del documento
    }
    return null; // Si el usuario no existe
  }
}
