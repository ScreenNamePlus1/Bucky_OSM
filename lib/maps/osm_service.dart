import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../maps_user.dart';

class OSMService {
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1'),
        headers: {'User-Agent': 'Bucky_OSM/1.0 (your-email@example.com)'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          return data.first;
        }
      } else {
        print('OSM Geocoding error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error geocoding address: $e');
    }
    return null;
  }

  static Future<void> showMap({
    required MapController controller,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await controller.setCenter(GeoPoint(latitude: latitude, longitude: longitude));
      await controller.setZoom(zoomLevel: 15);
      await controller.addMarker(
        GeoPoint(latitude: latitude, longitude: longitude),
        markerIcon: MarkerIcon(icon: Icon(Icons.location_pin, color: Colors.red)),
      );
    } catch (e) {
      print('Error showing map: $e');
    }
  }
}