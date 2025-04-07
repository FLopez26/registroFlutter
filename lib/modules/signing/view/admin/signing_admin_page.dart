import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichajes/models/app/admin_model.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:flutter/material.dart';

import '../../../profile/view/profile_page.dart';

class SigningAdminPage extends StatefulWidget {
  final String user;

  const SigningAdminPage({
    super.key,
    required this.user,
  });

  @override
  State<SigningAdminPage> createState() => _SigningAdminPageState();
}

class _SigningAdminPageState extends State<SigningAdminPage> {
  Admin? admin;
  List<User> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminAndEmployees();
  }

  Future<void> _loadAdminAndEmployees() async {
    try {
      // Buscar el admin por email
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: widget.user)
          .get();

      if (adminSnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final adminData = adminSnapshot.docs.first;
      final adminModel = Admin.fromMap(adminData.data(), adminData.id);
      final companyIds = adminModel.companies.map((c) => c.id).toList();

      // Buscar usuarios que estén en alguna de esas empresas
      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      final filteredUsers = usersSnapshot.docs.map((doc) {
        return User.fromMap(doc.data(), doc.id);
      }).where((user) {
        final userCompanyIds = user.companies.map((c) => c.id).toSet();
        return userCompanyIds.any((id) => companyIds.contains(id));
      }).toList();

      setState(() {
        admin = adminModel;
        employees = filteredUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Error al cargar datos de admin o empleados: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Vista de administrador"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: employees.isEmpty
            ? const Center(child: Text("No hay empleados asociados."))
            : ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final user = employees[index];
            final companyNames =
            user.companies.map((c) => c.name).join(' | ');

            return Card(
              color: user.working ? Colors.green : Colors.red,
              child: ListTile(
                title: Text(user.email),
                subtitle: Text("| $companyNames |"),
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Colors.white),
                  onPressed: () {
                    // Acción al presionar el botón
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}