import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/place.dart';

class LocationException implements Exception {
  final String mensaje;
  LocationException(this.mensaje);
  @override
  String toString() => mensaje;
}

class LocationService {
  LocationService._();

  static Future<Position> obtenerPosicionActual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(
        'La ubicación está desactivada. Actívala y pulsa Reintentar.',
      );
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw LocationException(
        'Permiso de ubicación denegado. Permite el acceso y pulsa Reintentar.',
      );
    }
    if (permiso == LocationPermission.deniedForever) {
      throw LocationException(
        'Permiso de ubicación bloqueado. Habilítalo para este sitio o aplicación y pulsa Reintentar.',
      );
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      throw LocationException(
        'No se obtuvo la ubicación a tiempo. Comprueba tu conexión y pulsa Reintentar.',
      );
    }
  }
}

double distanciaAPlaceEnMetros(Position origen, Place destino) =>
    Geolocator.distanceBetween(
      origen.latitude,
      origen.longitude,
      destino.lat,
      destino.lng,
    );

String formatearDistancia(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1)} km';
}
