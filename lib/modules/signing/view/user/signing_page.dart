import 'package:fichajes/constants/companies.dart';
import 'package:fichajes/models/app/company_model.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:fichajes/modules/geolocator/view/geolocator_page.dart';
import 'package:fichajes/utils/dialogs/confirm_signing_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../profile/view/profile_page.dart';

class SigningPage extends StatefulWidget {
  final User? user;

  const SigningPage({super.key, this.user});

  @override
  State<SigningPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? companySelected;
  String? locationSelected;
  List<String>? totalCompanies;

  @override
  void initState() {
    super.initState();
    totalCompanies = widget.user?.companies;
  }

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
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user?.email),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_pin),
            tooltip: 'Location',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationScreen(),
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
            child: Column(
              children: [
                const SizedBox(height: 40),

                StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                    Duration(seconds: 1),
                    (_) => DateTime.now().toLocal(),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();

                    String formattedTime =
                        "${snapshot.data!.hour.toString().padLeft(2, '0')}:"
                        "${snapshot.data!.minute.toString().padLeft(2, '0')}:"
                        "${snapshot.data!.second.toString().padLeft(2, '0')}";

                    return Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                DropdownButton<String>(
                  hint: const Text("Seleccione una empresa       "),
                  value: companySelected,
                  onChanged: (String? newValue) {
                    setState(() {
                      companySelected = newValue;
                      locationSelected = null;
                    });
                  },
                  items:
                      totalCompanies?.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 40),

                if (companySelected != null)
                  DropdownButton<String>(
                    hint: const Text("Seleccione un puesto            "),
                    value: locationSelected,
                    onChanged: (String? newValue) {
                      setState(() {
                        locationSelected = newValue;
                      });
                    },
                    items:
                        locationsFromCompany(
                          companySelected,
                        ).map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),

                Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 100, right: 20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 150,
                      height: 60,
                      child: ElevatedButton(

                        onPressed: _signing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Fichar",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> locationsFromCompany(String? company) {
    switch (company) {
      case "Empresa1":
        return optionsCompany1;
      case "Empresa2":
        return optionsCompany2;
      case "Empresa3":
        return optionsCompany3;
      case "Empresa4":
        return optionsCompany4;
      default:
        return [];
    }
  }

  void _signing() async {
    if (companySelected == null || locationSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debe seleccionar una empresa y un puesto")),
      );
      return;
    }

    Position? userPosition = await getCurrentLocation();
    if (userPosition == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("No se pudo obtener la ubicación."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
      return;
    }

    // Obtener la empresa más cercana
    Company? nearestCompany = getNearestLocation(userPosition);

    if (nearestCompany == null || companySelected != nearestCompany.name) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Ubicación incorrecta"),
          content: Text("No está en la ubicación correcta para fichar en $companySelected."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
      return;
    }

    // Si la ubicación es correcta, permitir el fichaje
    String currentTime = TimeOfDay.now().format(context);
    showDialog(
      context: context,
      builder: (context) => ConfirmSigningDialog(
        company: companySelected!,
        position: locationSelected!,
        time: currentTime,
      ),
    );
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Ubicación deshabilitada");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Permisos denegados permanentemente.");
        return null;
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Company? getNearestLocation(Position userPosition) {
    double minDistance = double.infinity;
    Company? nearestLocation;

    for (var company in companies) {
      double distance = Geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude,
        company.latitude, company.longitude,
      );

      if (distance < 1000 && distance < minDistance) {
        minDistance = distance;
        nearestLocation = company;
      }
    }

    return nearestLocation;
  }


}
