import 'package:fichajes/cubits/admin_cubit.dart';
import 'package:fichajes/cubits/company_cubit.dart';
import 'package:fichajes/cubits/workPoint_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/modules/login/view/login_page.dart';
import 'cubits/user_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FichajesApp());
}

class FichajesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (_) => UserCubit(),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(),
        ),
        BlocProvider<CompanyCubit>(
          create: (_) => CompanyCubit(),
        ),
        BlocProvider<WorkPointCubit>(
          create: (_) => WorkPointCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'fichajes',
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}