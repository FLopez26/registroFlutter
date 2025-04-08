import 'package:fichajes/models/app/admin_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app/user_model.dart';

class AdminCubit extends Cubit<List<Admin>> {
  AdminCubit() : super([]);

  Future<void> getAdmin(String documentId) async {
    try {
      final admin = await Admin.getAdmin(documentId);
      if (admin != null) {
        final adminWithCompanies = await _loadCompaniesForAdmin(admin, documentId);
        emit([adminWithCompanies]);
      } else {
        emit([]);
      }
    } catch (e) {
      print("Error al obtener admin con compañías: $e");
      emit([]);
    }
  }

  Future<void> getAllAdmins() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Admin').get();
      List<Admin> adminsWithCompanies = [];
      for (var doc in querySnapshot.docs) {
        var adminData = doc.data();
        var admin = Admin.fromMap(adminData, doc.id);
        final adminWithCompanies = await _loadCompaniesForAdmin(admin, doc.id);
        adminsWithCompanies.add(adminWithCompanies);
      }
      emit(adminsWithCompanies);
    } catch (e) {
      print("Error al obtener todos los admins con compañías: $e");
      emit([]);
    }
  }

  Future<void> saveAdmin(Admin admin) async {
    try {
      await admin.save();
      final adminWithCompanies = await _loadCompaniesForAdmin(admin, admin.id!);
      emit([adminWithCompanies]);
    } catch (e) {
      print("Error al guardar admin: $e");
    }
  }

  Future<Admin> _loadCompaniesForAdmin(Admin admin, String adminId) async {
    List<Company> companies = [];
    final adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();
    final companiesData = adminDoc.data()?['companies'];

    if (companiesData != null && companiesData is List) {
      for (var item in companiesData) {
        if (item is DocumentReference) {
          try {
            final companySnapshot = await item.get();
            if (companySnapshot.exists) {
              companies.add(Company.fromMap(companySnapshot.data() as Map<String, dynamic>, companySnapshot.id));
            }
          } catch (e) {
            print("Error al obtener compañía: $e");
          }
        } else if (item is Map<String, dynamic>) {
          companies.add(Company.fromMap(item, item['id']));
        }
      }
    }
    return Admin(
      id: admin.id,
      email: admin.email,
      password: admin.password,
      companies: companies,
    );
  }

  // Future<List<User>> getUsersFromCompanies(Admin admin) async {
  //   try {
  //     final companyIds = admin.companies.map((c) => c.id).toList();
  //
  //     if (companyIds.isEmpty) {
  //       return [];
  //     }
  //
  //     final usersSnapshot =
  //     await FirebaseFirestore.instance.collection('User').get();
  //
  //     final filteredUsers = usersSnapshot.docs.map((doc) {
  //       return User.fromMap(doc.data(), doc.id);
  //     }).where((user) {
  //       final userCompanyIds = user.companies.map((c) => c.id).toSet();
  //       return userCompanyIds.any((id) => companyIds.contains(id));
  //     }).toList();
  //
  //     return filteredUsers;
  //   } catch (e) {
  //     print("Error al obtener empleados de las empresas del admin: $e");
  //     return [];
  //   }
  // }

  Future<List<User>> getUsersFromCompanies(Admin admin) async {
    print("➡️ getUsersFromCompanies llamado para admin con ID: ${admin.id}");
    try {
      final companyIds = admin.companies.map((c) => c.id).toList();
      print("🏢 IDs de compañías del admin: $companyIds");

      if (companyIds.isEmpty) {
        print("⚠️ El admin no tiene compañías asociadas.");
        return [];
      }

      final usersSnapshot =
      await FirebaseFirestore.instance.collection('User').get();
      print("👤 Número de usuarios obtenidos de Firebase: ${usersSnapshot.docs.length}");

      final filteredUsers = usersSnapshot.docs.map((doc) {
        final user = User.fromMap(doc.data(), doc.id);
        print("➡️ Procesando usuario con ID: ${user.id}");
        return user;
      }).where((user) {
        final userCompanyIds = user.companies.map((companyRef) {
          if (companyRef is DocumentReference) {
            return companyRef.id;
          } else if (companyRef is String) {
            return companyRef; // Handle case where company is stored as String ID
          }
          return null;
        }).where((id) => id != null).toSet();

        print("   🔗 Compañías del usuario ${user.id} (IDs): $userCompanyIds");
        final isEmployee = userCompanyIds.any((id) => companyIds.contains(id));
        if (isEmployee) {
          print("   ✅ El usuario ${user.id} está asociado a una de las compañías del admin.");
        }
        return isEmployee;
      }).toList();

      print("✅ Número de empleados encontrados para el admin: ${filteredUsers.length}");
      return filteredUsers;
    } catch (e) {
      print("❌ Error al obtener empleados de las empresas del admin: $e");
      return [];
    }
  }
}