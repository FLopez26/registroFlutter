import 'package:flutter/material.dart';

class InfoSigningPage extends StatelessWidget {
  final String company;
  final String position;
  final String time;

  const InfoSigningPage({
    super.key,
    required this.company,
    required this.position,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fichaje Confirmado"),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Empresa: $company", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Puesto: $position", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Hora: $time", style: TextStyle(fontSize: 24))
          ],
        ),
      ),
    );
  }
}
