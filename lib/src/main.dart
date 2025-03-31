import 'package:flutter/material.dart';

import 'modules/login/view/login_page.dart';

void main() {
  runApp(fichajes());
}

class fichajes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fichajes',
      home: LoginPage(),
    );
  }
}