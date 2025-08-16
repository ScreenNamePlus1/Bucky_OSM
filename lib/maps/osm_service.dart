import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retry/retry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../utils/constants.dart';

class OSMService {
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final cacheKey = 'geocode_$address';
      final cachedResult = await _getCachedResult(cacheKey);
      if (cachedResult != null) return cachedResult;

      final response = await retry(
        () => http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$address'),
          headers: {'User-Agent': USER_AGENT},
        ),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          await _cacheResult(cacheKey, data[0]);
          return data[0];
        }
        throw Exception('No results found for address');
      }
      throw Exception('Geocoding failed: ${response.statusCode}');
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _getCachedResult(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);
    return cached != null ? jsonDecode(cached) : null;
  }

  static Future<void> _cacheResult(String key, Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(result));
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
  
  static Future<List<LatLng>?> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': USER_AGENT});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        return coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
      }
      throw Exception('Failed to get route: ${response.statusCode}');
    } catch (e) {
      print('Routing error: $e');
      return null;
    }
  }
}
