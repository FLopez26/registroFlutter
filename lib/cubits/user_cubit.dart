import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCubit extends Cubit<List<User>> {
  UserCubit() : super([]);

  // Método para obtener un solo usuario por su ID
  Future<void> getUser(String documentId) async {
    try {
      final user = await User.getUser(documentId);
      if (user != null) {
        emit([user]); // Emite el usuario como una lista de un solo elemento
      } else {
        emit([]); // Si no se encuentra el usuario, emite una lista vacía
      }
    } catch (e) {
      // Manejar errores si es necesario
      emit([]);
    }
  }

  // Método para obtener todos los usuarios desde Firestore
  Future<void> getAllUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('User').get();

      List<User> users = [];
      for (var doc in querySnapshot.docs) {
        var userData = doc.data();
        var user = User.fromMap(userData, doc.id);
        users.add(user);
      }

      emit(users); // Emite la lista de usuarios
    } catch (e) {
      // Manejar errores si es necesario
      emit([]);
    }
  }

  // Método para guardar un nuevo usuario
  Future<void> saveUser(User user) async {
    try {
      await user.save();
      emit([user]); // Emite el usuario guardado como una lista de un solo elemento
    } catch (e) {
      // Manejar errores si es necesario
    }
  }
}