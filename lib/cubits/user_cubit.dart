import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/user_model.dart';

class UserCubit extends Cubit<User?> {
  UserCubit() : super(null);

  Future<void> getUser(String documentId) async {
    try {
      final user = await User.getUser(documentId);
      emit(user); // Actualiza el estado con el usuario obtenido
    } catch (e) {
      // Manejar errores si es necesario
      emit(null);
    }
  }

  Future<void> saveUser(User user) async {
    try {
      await user.save();
      emit(user); // Emite el usuario guardado
    } catch (e) {
      // Manejar errores si es necesario
    }
  }
}