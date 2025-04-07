import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyCubit extends Cubit<List<Company>> {
  CompanyCubit() : super([]);

  // Método para obtener las compañías de un usuario
  Future<void> getCompanies(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final companiesReferences = userDoc.data()?['companies'] as List<DocumentReference>?;

      if (companiesReferences != null) {
        List<Company> companies = [];
        for (var ref in companiesReferences) {
          final companySnapshot = await ref.get();
          if (companySnapshot.exists) {
            companies.add(Company.fromMap(companySnapshot.data() as Map<String, dynamic>, companySnapshot.id));
          }
        }
        emit(companies);
      } else {
        emit([]);
      }
    } catch (e) {
      print("Error obteniendo compañías: $e");
      emit([]);
    }
  }

  // Método para guardar una compañía (esto podría necesitar más contexto sobre dónde se guarda la compañía)
  Future<void> saveCompany(Company company, String userId) async {
    try {
      await company.save(userId); // Assuming save method in Company model handles this
      // After saving, you might want to refresh the list of companies
      await getCompanies(userId);
    } catch (e) {
      print("Error guardando compañía: $e");
    }
  }
}