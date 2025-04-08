import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fichajes/cubits/user_cubit.dart';
import 'package:fichajes/cubits/admin_cubit.dart';

import '../../../models/app/admin_model.dart';
import '../../../models/app/user_model.dart';
import '../../signing/view/admin/signing_admin_page.dart';
import '../../signing/view/user/signing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().getAllUsers();
      print("Estado de UserCubit después de cargar:");
      print(context.read<UserCubit>().state);
      context.read<AdminCubit>().getAllAdmins();
    });
  }

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
    final userCubit = context.read<UserCubit>();
    final adminCubit = context.read<AdminCubit>();
    final trimmedEmail = email.trim();

    for (var admin in adminCubit.state) {
      if (admin.email.trim() == trimmedEmail) {
        emailTyped = trimmedEmail;
        return true;
      }
    }

    for (var user in userCubit.state) {
      if (user.email.trim() == trimmedEmail) {
        emailTyped = trimmedEmail;
        return true;
      }
    }

    return false;
  }

  bool _isValidPassword(String password) {
    final userCubit = context.read<UserCubit>();
    final adminCubit = context.read<AdminCubit>();
    final trimmedPassword = password.trim();

    for (var admin in adminCubit.state) {
      if (admin.password.trim() == trimmedPassword && admin.email.trim() == emailTyped) {
        passwordTyped = trimmedPassword;
        return true;
      }
    }

    for (var user in userCubit.state) {
      if (user.password.trim() == trimmedPassword && user.email.trim() == emailTyped) {
        passwordTyped = trimmedPassword;
        return true;
      }
    }

    return false;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Inicio de sesión exitoso")));
      FocusScope.of(context).unfocus();

      final adminCubit = context.read<AdminCubit>();
      Admin? adminSelected;

      for (var admin in adminCubit.state) {
        if (admin.email == emailTyped && admin.password == passwordTyped) {
          adminSelected = admin;
          break;
        }
      }

      if (adminSelected != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningAdminPage(admin: adminSelected!),
          ),
        );
      } else {
        final userCubit = context.read<UserCubit>();
        User? userSelected;

        for (var user in userCubit.state) {
          if (user.email == emailTyped && user.password == passwordTyped) {
            userSelected = user;
            break;
          }
        }

        if (userSelected != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SigningPage(user: userSelected!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuario o contraseña incorrectos")),
          );
        }
      }
    }
  }
}
