import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Future<Position?>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = getCurrentLocation();
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ubicación Actual")),
      body: Center(
        child: FutureBuilder<Position?>(
          future: _locationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return Text(
                "Latitud: ${snapshot.data!.latitude}\nLongitud: ${snapshot.data!.longitude}",
                textAlign: TextAlign.center,
              );
            } else {
              return Text("No se pudo obtener la ubicación.");
            }
          },
        ),
      ),
    );
  }
}
