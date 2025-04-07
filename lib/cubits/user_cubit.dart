import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCubit extends Cubit<List<User>> {
  UserCubit() : super([]);

  Future<void> getUser(String documentId) async {
    try {
      final user = await User.getUser(documentId);
      if (user != null) {
        final userWithCompanies = await _loadCompaniesForUser(user, documentId);
        emit([userWithCompanies]);
      } else {
        emit([]);
      }
    } catch (e) {
      print("Error al obtener usuario con compañías: $e");
      emit([]);
    }
  }

  Future<void> getAllUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('User').get();
      List<User> usersWithCompanies = [];
      for (var doc in querySnapshot.docs) {
        var userData = doc.data();
        var user = User.fromMap(userData, doc.id);
        final userWithCompanies = await _loadCompaniesForUser(user, doc.id);
        usersWithCompanies.add(userWithCompanies);
      }
      emit(usersWithCompanies);
    } catch (e) {
      print("Error al obtener todos los usuarios con compañías: $e");
      emit([]);
    }
  }

  Future<void> saveUser(User user) async {
    try {
      await user.save();
      final userWithCompanies = await _loadCompaniesForUser(user, user.id!);
      emit([userWithCompanies]);
    } catch (e) {
      print("Error al guardar usuario: $e");
    }
  }

  Future<User> _loadCompaniesForUser(User user, String userId) async {
    List<Company> companies = [];
    final userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();
    final companiesData = userDoc.data()?['companies'];

    if (companiesData != null && companiesData is List) {
      for (var item in companiesData) {
        if (item is DocumentReference) {
          try {
            final companySnapshot = await item.get();
            if (companySnapshot.exists) {
              companies.add(Company.fromMap(companySnapshot.data() as Map<String, dynamic>));
            }
          } catch (e) {
            print("Error al obtener compañía: $e");
          }
        } else if (item is Map<String, dynamic>) {
          companies.add(Company.fromMap(item));
        }
      }
    }
    return User(
      id: user.id,
      email: user.email,
      password: user.password,
      working: user.working,
      companies: companies,
    );
  }
}