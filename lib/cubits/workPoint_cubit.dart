import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/models/app/workPoint_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkPointCubit extends Cubit<List<WorkPoint>> {
  WorkPointCubit() : super([]);

  // Método para obtener los WorkPoints de una empresa
  Future<void> getWorkPoints(String companyId) async {
    try {
      final companyDoc = await FirebaseFirestore.instance
          .collection('Company')
          .doc(companyId)
          .get();

      if (companyDoc.exists) {
        final rawWorkPoints = companyDoc.data()?['workPoints'];

        if (rawWorkPoints != null && rawWorkPoints is List) {
          List<WorkPoint> workPoints = [];

          for (var workPointRef in rawWorkPoints) {
            if (workPointRef is DocumentReference) {
              if (workPointRef.parent.path == 'WorkPoint') {
                try {
                  final workPointSnapshot = await workPointRef.get();
                  if (workPointSnapshot.exists) {
                    final workPointData = workPointSnapshot.data();
                    if (workPointData != null && workPointData is Map<String, dynamic>) {
                      workPoints.add(WorkPoint.fromMap(workPointData)..id = workPointSnapshot.id);
                    } else {
                      print("⚠️ Datos vacíos o incorrectos en ${workPointRef.path}");
                    }
                  } else {
                    print("⚠️ Documento de WorkPoint no existe: ${workPointRef.path}");
                  }
                } catch (e) {
                  print("⚠️ Error al procesar ${workPointRef.path}: $e");
                }
              } else {
                print("⚠️ Referencia a WorkPoint incorrecta: ${workPointRef.path} no pertenece a la colección WorkPoint");
              }
            }
          }

          emit(workPoints);
        } else {
          print("⚠️ No hay referencias de WorkPoints en la compañía ${companyId}");
          emit([]);
        }
      } else {
        print("⚠️ Documento de la compañía no existe: $companyId");
        emit([]);
      }
    } catch (e) {
      print("❌ Error general obteniendo WorkPoints: $e");
      emit([]);
    }
  }

  // Método para guardar un WorkPoint
  Future<void> saveWorkPoint(WorkPoint workPoint, String userId, String companyId) async {
    try {
      final workPointRef = await FirebaseFirestore.instance
          .collection('WorkPoint')
          .add(workPoint.toMap());

      workPoint.id = workPointRef.id;

      final companyDocRef = FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .collection('companies')
          .doc(companyId);

      await companyDocRef.update({
        'workPoints': FieldValue.arrayUnion([workPointRef]),
      });

      await getWorkPoints(companyId);
    } catch (e) {
      print("❌ Error guardando WorkPoint: $e");
    }
  }

  // Método para eliminar un WorkPoint
  Future<void> deleteWorkPoint(String userId, String companyId, String workPointId) async {
    try {
      final workPointRefToDelete = FirebaseFirestore.instance
          .collection('WorkPoint')
          .doc(workPointId);

      final companyDocRef = FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .collection('companies')
          .doc(companyId);

      final workPointSnapshotToDelete = await workPointRefToDelete.get();

      if (workPointSnapshotToDelete.exists) {
        await companyDocRef.update({
          'workPoints': FieldValue.arrayRemove([workPointSnapshotToDelete.reference]),
        });

        await workPointRefToDelete.delete();

        await getWorkPoints(companyId);
      } else {
        print("⚠️ No se encontró el WorkPoint a eliminar.");
      }
    } catch (e) {
      print("❌ Error eliminando WorkPoint: $e");
    }
  }
}