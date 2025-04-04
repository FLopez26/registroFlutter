import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/cubits/user_cubit.dart';
import 'package:fichajes/cubits/admin_cubit.dart';

import '../../../models/app/user_model.dart';
import '../../signing/view/admin/signing_admin_page.dart';
import '../../signing/view/user/signing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static bool isAdminEmail = false;
  static bool isAdminPass = false;
  late String emailTyped;
  late String passwordTyped;

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
                    return "Correo no válido";
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
    bool emailFound = false;
    final userCubit = context.read<UserCubit>();
    final adminCubit = context.read<AdminCubit>();

    // Obtener todos los usuarios y administradores
    userCubit.getAllUsers();
    adminCubit.getAllAdmins();

    // Comprobar si el correo está en los administradores
    adminCubit.state.forEach((admin) {
      if (admin.email == email) {
        isAdminEmail = true;
        emailTyped = email;
        emailFound = true;
      }
    });

    // Comprobar si el correo está en los usuarios
    if (!emailFound) {
      userCubit.state.forEach((user) {
        if (user.email == email) {
          emailTyped = email;
          emailFound = true;
        }
      });
    }

    return emailFound;
  }

  bool _isValidPassword(String password) {
    bool passwordValid = false;

    final userCubit = context.read<UserCubit>();
    final adminCubit = context.read<AdminCubit>();

    // Si es admin, se valida la contraseña con los administradores
    if (isAdminEmail) {
      adminCubit.state.forEach((admin) {
        if (admin.password == password && admin.email == emailTyped) {
          passwordTyped = password;
          isAdminPass = true;
          passwordValid = true;
        }
      });
    }

    // Si no es admin, se valida con los usuarios
    if (!isAdminEmail) {
      userCubit.state.forEach((user) {
        if (user.password == password && user.email == emailTyped) {
          passwordTyped = password;
          passwordValid = true;
        }
      });
    }

    return passwordValid;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicio de sesión exitoso")),
      );
      FocusScope.of(context).unfocus();

      // Si es un administrador
      if (isAdminEmail && isAdminPass) {
        isAdminEmail = false;
        isAdminPass = false;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningAdminPage(user: "Administrator"),
          ),
        );
      } else {
        // Si no es un administrador, buscamos al usuario
        late User userSelected;

        // Busca el usuario que coincide con el email y la contraseña
        final userCubit = context.read<UserCubit>();
        userCubit.state.forEach((user) {
          if (user.email == emailTyped && user.password == passwordTyped) {
            userSelected = user;
          }
        });

        // Navegar a la página de usuario
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningPage(user: userSelected),
          ),
        );
      }
    }
  }
}