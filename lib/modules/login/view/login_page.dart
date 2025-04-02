import 'package:fichajes/constants/access.dart';
import 'package:fichajes/constants/users.dart';
import 'package:fichajes/modules/signing/view/admin/signing_admin_page.dart';
import 'package:flutter/material.dart';

import '../../signing/view/user/signing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static bool isAdminEmail = false;
  static bool isAdminPass = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de sesión"),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese un correo";
                  } else if (!_isValidEmail(value)) {
                    return "Ingrese un correo válido";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese una contraseña";
                  } else if (!_isValidPassword(value)) {
                    return "Contraseña incorrecta";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: _login, child: const Text('Login')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    /*final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);*/
    if(adminEmail == email){
      isAdminEmail = true;
      return true;
    }
    for(var user in users){
      if(user.email == email){return true;}
    }
    return false;
  }

  bool _isValidPassword(String password) {
    /*return password.trim().length >= 6;*/
    if(adminPassword == password){
      isAdminPass = true;
      return true;
    }
    for(var user in users){
      if(user.password == password){return true;}
    }
    return false;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicio de sesión exitoso")),
      );
      FocusScope.of(context).unfocus();
      if(isAdminEmail == true && isAdminPass == true){
        isAdminEmail = false;
        isAdminPass = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningAdminPage(userEmail: _emailController.text),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningPage(userEmail: _emailController.text),
          ),
        );
      }
    }
  }
}
