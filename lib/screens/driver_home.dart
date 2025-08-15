// lib/screens/driver_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:bucky_osm/maps/osm_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final MapController _mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Home')),
      body: OSMFlutter(
        controller: _mapController,
        trackMyPosition: true,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        onMapIsReady: () async {
          await OSMService.showMap(
            controller: _mapController,
            latitude: 37.7749,
            longitude: -122.4194,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await OSMService.geocodeAddress('380 New York St, Redlands, CA');
          if (result != null) {
            await _mapController.setCenter(
              GeoPoint(
                latitude: double.parse(result['lat']),
                longitude: double.parse(result['lon']),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Geocoding failed')),
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