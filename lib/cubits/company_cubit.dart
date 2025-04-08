import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyCubit extends Cubit<List<Company>> {
  CompanyCubit() : super([]);

  // Método para obtener las compañías de un usuario
  Future<void> getCompanies(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();
      final rawRefs = userDoc.data()?['companies'];

      if (rawRefs != null && rawRefs is List) {
        final companiesReferences = rawRefs
            .where((e) => e is DocumentReference)
            .cast<DocumentReference>()
            .toList();
        List<Company> companies = [];

        for (var ref in companiesReferences) {
          try {
            final snapshot = await ref.get();
            if (snapshot.exists) {
              final data = snapshot.data();
              if (data != null && data is Map<String, dynamic>) {
                companies.add(Company.fromMap(data, snapshot.id));
              } else {
                print("⚠️ Datos vacíos o incorrectos en ${ref.path}");
              }
            } else {
              print("⚠️ Documento no existe: ${ref.path}");
            }
          } catch (e) {
            print("⚠️ Error al procesar ${ref.path}: $e");
          }
        }

        emit(companies);
      } else {
        print("⚠️ No hay referencias de compañías en el documento de usuario");
        emit([]);
      }
    } catch (e) {
      print("❌ Error general obteniendo compañías: $e");
      emit([]);
    }
  }

  // Método para guardar una compañía (esto podría necesitar más contexto sobre dónde se guarda la compañía)
  Future<void> saveCompany(Company company, String userId) async {
    try {
      await company.save(userId);
      await getCompanies(userId);
    } catch (e) {
      print("Error guardando compañía: $e");
    }
  }
}