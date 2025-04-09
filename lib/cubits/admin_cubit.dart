import 'package:fichajes/models/app/admin_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:fichajes/cubits/user_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app/user_model.dart';

class AdminCubit extends Cubit<List<Admin>> {
  AdminCubit() : super([]);

  Future<void> getAdmin(String documentId) async {
    try {
      final admin = await Admin.getAdmin(documentId);
      if (admin != null) {
        final adminWithCompanies = await _loadCompaniesForAdmin(
          admin,
          documentId,
        );
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
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Admin').get();
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
    final adminDoc =
        await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();
    final companiesData = adminDoc.data()?['companies'];

    if (companiesData != null && companiesData is List) {
      for (var item in companiesData) {
        if (item is DocumentReference) {
          try {
            final companySnapshot = await item.get();
            if (companySnapshot.exists) {
              companies.add(
                Company.fromMap(
                  companySnapshot.data() as Map<String, dynamic>,
                  companySnapshot.id,
                ),
              );
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

  Future<List<User>> getUsersFromCompanies(Admin admin) async {
    List<User> usersInAdminCompanies = [];
    try {
      final adminCompanyIds = admin.companies.map((c) => c.id).toSet();
      final usersSnapshot = await FirebaseFirestore.instance.collection('User').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        if (userData.containsKey('companies')) {
          List<String> userCompanyIds = [];
          final companiesData = userData['companies'];
          if (companiesData != null && companiesData is List) {
            for (var item in companiesData) {
              if (item is DocumentReference) {
                userCompanyIds.add(item.id);
              } else if (item is Map<String, dynamic> && item.containsKey('id')) {
                userCompanyIds.add(item['id']);
              }
            }
          }

          if (userCompanyIds.any((id) => adminCompanyIds.contains(id))) {
            final basicUser = User(
              id: userDoc.id,
              email: userData['email'] ?? '',
              password: userData['password'] ?? '',
              working: userData['working'] ?? false,
              companies: [],
            );
            final userWithCompanies = await UserCubit().loadCompaniesForUser(basicUser, userDoc.id);
            usersInAdminCompanies.add(userWithCompanies);
          }
        }
      }
      return usersInAdminCompanies;
    } catch (e) {
      print("Error getting users from companies: $e");
      return [];
    }
  }
}
