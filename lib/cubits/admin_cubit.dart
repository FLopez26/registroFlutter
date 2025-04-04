import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/admin_model.dart';

class AdminCubit extends Cubit<Admin?> {
  AdminCubit() : super(null);

  Future<void> getAdmin(String documentId) async {
    try {
      final admin = await Admin.getAdmin(documentId);
      emit(admin); // Actualiza el estado con el administrador obtenido
    } catch (e) {
      // Manejar errores si es necesario
      emit(null);
    }
  }

  Future<void> saveAdmin(Admin admin) async {
    try {
      await admin.save();
      emit(admin); // Emite el administrador guardado
    } catch (e) {
      // Manejar errores si es necesario
    }
  }
}