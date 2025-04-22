import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ORSService {
  static const String apiKey = "5b3ce3597851110001cf62486c7c8af74cf646be838f6fc698c67fa8"; // Substitui com tua chave da OpenRouteService

  static Future<LatLng> getCoordenadas(String endereco) async {
    final url = Uri.parse(
        'https://api.openrouteservice.org/geocode/search?api_key=$apiKey&text=$endereco');

    final response = await http.get(url);
    final data = json.decode(response.body);

    final coords = data['features'][0]['geometry']['coordinates'];
    return LatLng(coords[1], coords[0]);
  }

  static Future<List<LatLng>> calcularRota(LatLng origem, LatLng destino) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-hgv/geojson');

    final body = json.encode({
      'coordinates': [
        [origem.longitude, origem.latitude],
        [destino.longitude, destino.latitude]
      ]
    });

    final response = await http.post(url,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json'
        },
        body: body);

    final data = json.decode(response.body);
    final coords = data['features'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }
}
