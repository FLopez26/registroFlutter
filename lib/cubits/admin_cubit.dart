import 'package:fichajes/models/app/admin_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}