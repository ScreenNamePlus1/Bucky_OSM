import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/osm_service.dart';
import '../providers.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final MapController _mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  );

  // New variable to hold the route
  List<GeoPoint> routePoints = [];

  // New method to draw the route
  Future<void> _drawRoute(GeoPoint start, GeoPoint end) async {
    final startLatLng = LatLng(start.latitude, start.longitude);
    final endLatLng = LatLng(end.latitude, end.longitude);
    final route = await OSMService.getRoute(start: startLatLng, end: endLatLng);
    if (route != null) {
      setState(() {
        routePoints = route.map((p) => GeoPoint(latitude: p.latitude, longitude: p.longitude)).toList();
      });
      await _mapController.drawRoadManually(routePoints, 'route');
      await _mapController.zoomToBoundingBox(BoundingBox.fromGeoPoints(routePoints), step: 1.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Home')),
      body: OSMFlutter(
        controller: _mapController,
        trackMyPosition: true,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        onMapIsReady: () async {
          try {
            final position = await ref.read(locationServiceProvider).getCurrentLocation();
            await OSMService.showMap(
              controller: _mapController,
              latitude: position.latitude,
              longitude: position.longitude,
            );
            // Example usage: To draw a route from current location to a hard-coded address.
            // In a real app, this would be triggered by a user action like accepting a request.
            // final destination = await OSMService.geocodeAddress('380 New York St, Redlands, CA');
            // if (destination != null) {
            //   await _drawRoute(GeoPoint(latitude: position.latitude, longitude: position.longitude), GeoPoint(latitude: double.parse(destination['lat']), longitude: double.parse(destination['lon'])));
            // }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error centering map: $e')),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await OSMService.geocodeAddress('380 New York St, Redlands, CA');
          if (result != null) {
            final destination = GeoPoint(
              latitude: double.parse(result['lat']),
              longitude: double.parse(result['lon']),
            );
            await _mapController.setCenter(destination);
            await _mapController.addMarker(
              destination,
              markerIcon: const MarkerIcon(icon: Icon(Icons.location_pin, color: Colors.blue)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Geocoding failed. Please check the address or try again.')),
            );
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
