import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';

class CompanyCubit extends Cubit<List<Company>> {
  CompanyCubit() : super([]);

  Future<void> getCompanies(String userId) async {
    try {
      final companies = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('companies')
          .get()
          .then((snapshot) => snapshot.docs
          .map((doc) => Company.fromMap(doc.data()))
          .toList());

      emit(companies); // Actualiza el estado con las empresas obtenidas
    } catch (e) {
      // Manejar errores si es necesario
      emit([]);
    }
  }

  Future<void> saveCompany(Company company, String userId) async {
    try {
      await company.save(userId);
      // No es necesario emitir un estado después de guardar
    } catch (e) {
      // Manejar errores si es necesario
    }
  }
}
