import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/place.dart';

class OverpassService {
  static Future<List<Place>> buscarPostosProximos(List<LatLng> rota, double raioKm) async {
    final buffer = StringBuffer();
    final raio = (raioKm * 1000).toInt();

    for (var ponto in rota) {
      buffer.writeln('node["amenity"="fuel"](around:$raio,${ponto.latitude},${ponto.longitude});');
    }

    final query = """
      [out:json];
      (
        ${buffer.toString()}
      );
      out center;
    """;

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    final response = await http.post(url, body: {'data': query});

    final data = json.decode(response.body);
    final elementos = data['elements'] as List;

    return elementos.map((e) {
      final nome = e['tags']?['name'] ?? 'Posto sem nome';
      final lat = e['lat']?.toDouble();
      final lon = e['lon']?.toDouble();
      return Place(nome: nome, coordenadas: LatLng(lat, lon));
    }).toList();
  }
}