import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/workPoint_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkPointCubit extends Cubit<List<WorkPoint>> {
  WorkPointCubit() : super([]);

  // Método para obtener los puntos de trabajo de una compañía
  Future<void> getWorkPoints(String userId, String companyId) async {
    try {
      final workPoints = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(companyId)
          .collection('workPoints')
          .get()
          .then((snapshot) => snapshot.docs
          .map((doc) => WorkPoint.fromMap(doc.data()))
          .toList());

      emit(workPoints); // Emitir la nueva lista de WorkPoints
    } catch (e) {
      print("Error obteniendo WorkPoints: $e");
      emit([]); // Emitir una lista vacía en caso de error
    }
  }

  // Método para guardar un WorkPoint
  Future<void> saveWorkPoint(WorkPoint workPoint, String userId, String companyId) async {
    try {
      await workPoint.save(userId, companyId); // Guardamos el WorkPoint en Firestore
      // Después de guardar, obtenemos de nuevo la lista de WorkPoints
      await getWorkPoints(userId, companyId);
    } catch (e) {
      print("Error guardando WorkPoint: $e");
    }
  }

  // Método para eliminar un WorkPoint
  Future<void> deleteWorkPoint(String userId, String companyId, String workPointId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(companyId)
          .collection('workPoints')
          .doc(workPointId)
          .delete();

      // Después de eliminarlo, obtenemos la lista actualizada de WorkPoints
      await getWorkPoints(userId, companyId);
    } catch (e) {
      print("Error eliminando WorkPoint: $e");
    }
  }
}