import 'package:cloud_firestore/cloud_firestore.dart';

import 'company_model.dart';

class Admin {
  final String email;
  final String password;
  List<Company> companies;
  String? id;

  Admin({
    required this.email,
    required this.password,
    required this.companies,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'companies': companies.map((company) => company.toMap()).toList(),
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map, String documentId) {
    var companiesList = <Company>[];
    if (map['companies'] != null && map['companies'] is List) {
      companiesList = (map['companies'] as List<dynamic>)
          .map((companyData) {
        if (companyData is DocumentReference) {
          return Company(id: companyData.id, name: '', workPoints: []);
        } else if (companyData is Map<String, dynamic>) {
          return Company.fromMap(companyData, companyData['id'] ?? '');
        }
        return Company(id: '', name: '', workPoints: []);
      }).toList();
    }
    return Admin(
      id: documentId,
      email: map['email'],
      password: map['password'],
      companies: companiesList,
    );
  }

  // Método para guardar el administrador en Firestore
  Future<void> save() async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc();
    this.id = adminRef.id;
    await adminRef.set(toMap());
  }

  // Método para obtener un administrador desde Firestore
  static Future<Admin?> getAdmin(String documentId) async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(documentId);
    final docSnapshot = await adminRef.get();

    if (docSnapshot.exists) {
      return Admin.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }
}