import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
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
            await _mapController.setCenter(
              GeoPoint(
                latitude: double.parse(result['lat']),
                longitude: double.parse(result['lon']),
              ),
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
```