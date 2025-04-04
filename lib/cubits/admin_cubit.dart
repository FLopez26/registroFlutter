import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/admin_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCubit extends Cubit<List<Admin>> {
  AdminCubit() : super([]);

  // Método para obtener un solo administrador por su ID
  Future<void> getAdmin(String documentId) async {
    try {
      final admin = await Admin.getAdmin(documentId);
      if (admin != null) {
        emit([admin]); // Emite el administrador como una lista de un solo elemento
      } else {
        emit([]); // Si no se encuentra el administrador, emite una lista vacía
      }
    } catch (e) {
      // Manejar errores si es necesario
      emit([]);
    }
  }

  // Método para obtener todos los administradores desde Firestore
  Future<void> getAllAdmins() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Admin').get();

      List<Admin> admins = [];
      for (var doc in querySnapshot.docs) {
        var adminData = doc.data();
        var admin = Admin.fromMap(adminData, doc.id);
        admins.add(admin);
      }

      emit(admins); // Emite la lista de administradores
    } catch (e) {
      // Manejar errores si es necesario
      emit([]);
    }
  }

  // Método para guardar un nuevo administrador
  Future<void> saveAdmin(Admin admin) async {
    try {
      await admin.save();
      emit([admin]); // Emite el administrador guardado como una lista de un solo elemento
    } catch (e) {
      // Manejar errores si es necesario
    }
  }
}