import 'package:fichajes/constants/companies.dart';
import 'package:fichajes/constants/users.dart';
import 'package:flutter/material.dart';

import '../../../profile/view/profile_page.dart';

class SigningAdminPage extends StatefulWidget {
  final String userEmail;

  const SigningAdminPage({
    super.key,
    required this.userEmail
  });

  @override
  State<SigningAdminPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningAdminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? companySelected;
  String? locationSelected;
  List<String> totalCompanies = companies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Vista de administrador"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userEmail: widget.userEmail),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: double.infinity,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: user.working ? Colors.green : Colors.red,
                  child: ListTile(
                    title: Text(user.email),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("| ${user.companies.join(' | ')} |")
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      onPressed: () {
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
