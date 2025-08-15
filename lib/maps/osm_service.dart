// lib/maps/osm_service.dart
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OSMService {
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$address'),
        headers: {'User-Agent': 'Bucky_OSM/1.0 (screennameplus1@example.com)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
        throw Exception('No results found for address');
      }
      throw Exception('Geocoding failed: ${response.statusCode}');
    } catch (e) {
      print('Geocoding error: $e');
      return null; // Fallback for missing data
    }
  }

  static Future<void> showMap({
    required MapController controller,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await controller.setCenter(GeoPoint(latitude: latitude, longitude: longitude));
      await controller.setZoom(zoomLevel: 15);
    } catch (e) {
      print('Map rendering error: $e');
    }
  }
}
