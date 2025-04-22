import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMarkers {
  static Marker origem(LatLng posicao) {
    return Marker(
      point: posicao,
      width: 40,
      height: 40,
      builder: (context) => const Icon(
        Icons.local_shipping,
        color: Colors.red,
        size: 40,
      ),
    );
  }

  static Marker destino(LatLng posicao) {
    return Marker(
      point: posicao,
      width: 40,
      height: 40,
      builder: (context) => const Icon(
        Icons.flag,
        color: Colors.blue,
        size: 40,
      ),
    );
  }

  static Marker posto(LatLng posicao) {
    return Marker(
      point: posicao,
      width: 30,
      height: 30,
      builder: (context) => const Icon(
        Icons.local_gas_station,
        color: Colors.green,
        size: 30,
      ),
    );
  }
}