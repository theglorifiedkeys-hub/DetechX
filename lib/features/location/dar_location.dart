import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const darAreas = <String, LatLng>{
  'Mikocheni': LatLng(-6.7706, 39.2512),
  'Sinza': LatLng(-6.7902, 39.2259),
  'Kinondoni': LatLng(-6.7900, 39.2564),
  'Mbezi Beach': LatLng(-6.7020, 39.2340),
  'Upanga': LatLng(-6.8056, 39.2813),
  'Kigamboni': LatLng(-6.8270, 39.3200),
  'Masaki': LatLng(-6.7463, 39.2856),
  'Ubungo': LatLng(-6.7944, 39.2087),
  'Tegeta': LatLng(-6.6679, 39.1817),
  'Mbagala': LatLng(-6.9260, 39.2755),
  'Tabata': LatLng(-6.8290, 39.2154),
  'Gongo la Mboto': LatLng(-6.8778, 39.1670),
};

String? suggestDarArea(LatLng point, double accuracyMeters) {
  if (!accuracyMeters.isFinite ||
      accuracyMeters <= 0 ||
      accuracyMeters > 2500) {
    return null;
  }
  String? closest;
  var distance = 5000.0;
  for (final area in darAreas.entries) {
    final meters = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      area.value.latitude,
      area.value.longitude,
    );
    if (meters < distance) {
      distance = meters;
      closest = area.key;
    }
  }
  return closest;
}

class LocationProblem implements Exception {
  const LocationProblem(this.message);
  final String message;
}

Future<Position> readDevicePosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LocationProblem(
      'Washa huduma ya eneo kwenye simu, kisha jaribu tena.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const LocationProblem(
      'Ruhusu eneo kwenye mipangilio, au chagua mtaa mwenyewe.',
    );
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 12),
    ),
  );
}
