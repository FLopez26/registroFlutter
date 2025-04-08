import 'package:fichajes/cubits/admin_cubit.dart';
import 'package:fichajes/models/app/admin_model.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/view/user/profile_page.dart';

class SigningAdminPage extends StatefulWidget {
  final Admin admin;

  const SigningAdminPage({
    super.key,
    required this.admin,
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
    admin = widget.admin;
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      isLoading = true;
      employees = [];
    });
    if (admin != null) {
      final adminCubit = context.read<AdminCubit>();
      final fetchedEmployees = await adminCubit.getUsersFromCompanies(admin!);
      setState(() {
        employees = fetchedEmployees;
        isLoading = false;
      });
    } else {
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
        title: const Text("Vista de Administrador"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.admin.email),
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