import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import '../services/ors_service.dart';
import '../services/overpass_service.dart';
import '../models/place.dart';
import '../widgets/custom_markers.dart';

class MapaScreen extends StatefulWidget {
  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  List<LatLng> rota = [];
  List<Place> postos = [];
  LatLng? origem;
  LatLng? destino;
  bool carregando = false;

  final TextEditingController _origemController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _origemController.text = "Fortaleza, Ceará";
    _destinoController.text = "Parazinho, Ceará";
    carregarDados(); // carrega valores iniciais
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);
    try {
      origem = await ORSService.getCoordenadas(_origemController.text);
      destino = await ORSService.getCoordenadas(_destinoController.text);
      rota = await ORSService.calcularRota(origem!, destino!);
      postos = await OverpassService.buscarPostosProximos(rota, 5.0);
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<List<String>> sugestoesEndereco(String query) async {
    if (query.isEmpty) return [];
    try {
      List<Location> locations = await locationFromAddress(query);
      return locations.map((loc) => "${loc.latitude},${loc.longitude}").toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> buscarPorTexto(String texto, TextEditingController controller, bool isOrigem) async {
    try {
      final coordenadas = await ORSService.getCoordenadas(texto);
      setState(() {
        if (isOrigem) {
          origem = coordenadas;
        } else {
          destino = coordenadas;
        }
      });
      await carregarDados();
    } catch (e) {
      print("Erro ao buscar endereço: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rota com Postos"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _origemController,
                    decoration: InputDecoration(
                      labelText: 'Origem',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  suggestionsCallback: (pattern) async =>
                      await ORSService.sugerirEnderecos(pattern),
                  itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                  onSuggestionSelected: (suggestion) {
                    _origemController.text = suggestion;
                    buscarPorTexto(suggestion, _origemController, true);
                  },
                ),
                SizedBox(height: 10),
                TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _destinoController,
                    decoration: InputDecoration(
                      labelText: 'Destino',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.flag),
                    ),
                  ),
                  suggestionsCallback: (pattern) async =>
                      await ORSService.sugerirEnderecos(pattern),
                  itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                  onSuggestionSelected: (suggestion) {
                    _destinoController.text = suggestion;
                    buscarPorTexto(suggestion, _destinoController, false);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: carregando || origem == null || destino == null
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      center: origem,
                      zoom: 7,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.erick.routemap',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: rota,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: origem!,
                            width: 40,
                            height: 40,
                            builder: (ctx) => CustomMarkers.origem(),
                          ),
                          Marker(
                            point: destino!,
                            width: 40,
                            height: 40,
                            builder: (ctx) => CustomMarkers.destino(),
                          ),
                          ...postos.map((posto) => Marker(
                                point: posto.coordenadas,
                                width: 40,
                                height: 40,
                                builder: (ctx) => CustomMarkers.posto(posto),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}