import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_model.dart';

class User {
  final String email;
  final String password;
  bool working; // True trabajando, false no
  List<Company> companies;
  String? id;

  User({
    required this.email,
    required this.password,
    this.working = false,
    required this.companies,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'working': working,
      'companies': companies.map((company) => company.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      email: map['email'],
      password: map['password'],
      working: map['working'] ?? false,
      companies: [],
    );
  }

  // Método para guardar el usuario en Firestore
  Future<void> save() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc();
    this.id = userRef.id;
    await userRef.set(toMap());
  }

  // Método para obtener un usuario desde Firestore (without loading companies)
  static Future<User?> getUser(String documentId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(documentId);
    final docSnapshot = await userRef.get();

    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }
}