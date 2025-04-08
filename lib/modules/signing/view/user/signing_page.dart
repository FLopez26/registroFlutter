import 'package:fichajes/models/app/company_model.dart';
import 'package:fichajes/models/app/user_model.dart';
import 'package:fichajes/modules/geolocator/view/geolocator_page.dart';
import 'package:fichajes/utils/dialogs/confirm_signing_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../cubits/company_cubit.dart';
import '../../../../cubits/user_cubit.dart';
import '../../../../cubits/workPoint_cubit.dart';
import '../../../../models/app/workPoint_model.dart';
import '../../../profile/view/user/profile_page.dart';

class SigningPage extends StatefulWidget {
  final User user;

  const SigningPage({super.key, required this.user});

  @override
  State<SigningPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningPage> {
  String? companySelectedId;
  String? workPointSelectedName;
  List<Company> companies = [];
  List<WorkPoint> workPoints = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    await context.read<CompanyCubit>().getCompanies(widget.user.id!);
    setState(() {
      companies = context.read<CompanyCubit>().state;
    });
  }

  Future<void> _loadWorkPoints(String companyId) async {
    await context.read<WorkPointCubit>().getWorkPoints(companyId);
    setState(() {
      workPoints = context.read<WorkPointCubit>().state;
      workPointSelectedName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Fichar"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(user: widget.user.email),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                    (_) => DateTime.now().toLocal(),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final time = snapshot.data!;
                final formatted = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";

                return Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Dropdown de empresa
            DropdownButton<String>(
              hint: const Text("Seleccione una empresa"),
              value: companySelectedId,
              isExpanded: true,
              items: companies.map((company) {
                return DropdownMenuItem<String>(
                  value: company.id,
                  child: Text(company.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  companySelectedId = value;
                  workPoints.clear();
                  workPointSelectedName = null;
                });
                if (value != null) {
                  _loadWorkPoints(value);
                }
              },
            ),
            const SizedBox(height: 40),

            // Dropdown de WorkPoints
            if (companySelectedId != null)
              DropdownButton<String>(
                hint: const Text("Seleccione un puesto"),
                value: workPointSelectedName,
                isExpanded: true,
                items: workPoints.map((wp) {
                  return DropdownMenuItem<String>(
                    value: wp.name,
                    child: Text(wp.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    workPointSelectedName = value;
                  });
                },
              ),

            const Spacer(),

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
    );
  }

  void _signing() async {
    if (companySelectedId == null || workPointSelectedName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe seleccionar una empresa y un puesto")),
      );
      return;
    }

    final position = await getCurrentLocation();
    if (position == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Error"),
          content: Text("No se pudo obtener la ubicación."),
        ),
      );
      return;
    }

    final selectedWorkPoint = workPoints.firstWhere(
          (wp) => wp.name == workPointSelectedName,
    );

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      selectedWorkPoint.latitude,
      selectedWorkPoint.longitude,
    );

    if (distance > 1000) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Ubicación incorrecta"),
          content: Text("No está en la ubicación correcta para fichar en ${selectedWorkPoint.name}."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
      return;
    }

    context.read<UserCubit>().updateWorkingStatus(widget.user.id!);

    final currentTime = TimeOfDay.now().format(context);
    showDialog(
      context: context,
      builder: (_) => ConfirmSigningDialog(
        company: companies.firstWhere((c) => c.id == companySelectedId).name,
        position: selectedWorkPoint.name,
        time: currentTime
      ),
    );
  }

  Future<Position?> getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

}