import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MapNavigationApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class MapNavigationApp extends StatefulWidget {
  const MapNavigationApp({super.key});

  @override
  State<MapNavigationApp> createState() => _MapNavigationAppState();
}

class _MapNavigationAppState extends State<MapNavigationApp> {
  late MapController _mapController;
  LatLng _currentPosition = const LatLng(-3.7327, -38.5270); // Fortaleza como padrão
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  double? _routeDistance;
  double? _routeDuration;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: ${e.toString()}')),
      );
    }
  }

  Future<void> _calculateRoute(LatLng destination) async {
    setState(() {
      _isLoading = true;
      _destination = destination;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_currentPosition.longitude},${_currentPosition.latitude};'
        '${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _routeDistance = data['routes'][0]['distance'] / 1000; // em km
          _routeDuration = data['routes'][0]['duration'] / 60; // em minutos
          _routePoints = (data['routes'][0]['geometry']['coordinates'] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao calcular rota: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _destination = null;
      _routePoints.clear();
      _routeDistance = null;
      _routeDuration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegação com OpenStreetMap'),
        actions: [
          if (_destination != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearRoute,
              tooltip: 'Limpar rota',
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition,
              zoom: 15.0,
              onTap: (_, latlng) => _calculateRoute(latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    builder: (ctx) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      width: 40,
                      height: 40,
                      builder: (ctx) => const Icon(
                        Icons.flag,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_routeDistance != null && _routeDuration != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distância: ${_routeDistance!.toStringAsFixed(2)} km'),
                      Text('Tempo estimado: ${_routeDuration!.toStringAsFixed(2)} min'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}