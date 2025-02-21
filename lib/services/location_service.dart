import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationPermissionDenied implements Exception {
  String errorMessage() {
    return 'Location permission denied by user.';
  }
}

Future<bool> _showLocationDisclosure(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Permission Disclosure'),
        content: const Text(
            'This app needs access to location to provide accurate prayer times based on your current location. '
            'We only access your location when the app is in use to calculate prayer times. '),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<Position> determinePosition([BuildContext? context]) async {
  bool serviceEnabled;
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    if (context != null) {
      await _showLocationDisclosure(context);

      permission = await Geolocator.requestPermission();
    }
  }

  Position? position = await Geolocator.getLastKnownPosition();
  if (position != null) {
    return position;
  } else {
    return await Geolocator.getCurrentPosition();
  }
}

Future<Coordinates> getPositionCoordinates([BuildContext? context]) async {
  try {
    Position position = await determinePosition(context);
    return Coordinates(position.latitude, position.longitude);
  } catch (e) {
    return Coordinates(46.2276, 2.2137);
  }
}
