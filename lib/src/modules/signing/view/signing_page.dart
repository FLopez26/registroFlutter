import 'package:fichajes/src/constants/companies.dart';
import 'package:flutter/material.dart';

class SigningPage extends StatefulWidget {
  const SigningPage({super.key});

  @override
  State<SigningPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? companySelected;
  String? locationSelected;
  List<String> totalCompanies = companies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Datos"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 30),

                DropdownButton<String>(
                  hint: Text("Seleccione una empresa        "),
                  value: companySelected,
                  onChanged: (String? newValue) {
                    setState(() {
                      companySelected = newValue;
                    });
                  },
                  items:
                      companies.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 30),

                DropdownButton<String>(
                  hint: Text("Seleccione un puesto          "),
                  value: locationSelected,
                  onChanged: (String? newValue) {
                    setState(() {
                      locationSelected = newValue;
                    });
                  },
                  items:
                      companies.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> locationsFromCompany(String company) {
    List<String> locations;
    locations = ["w"];
    return locations;
  }
}
