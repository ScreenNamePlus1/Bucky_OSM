import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/request.dart';
import '../providers.dart';

class TrackingScreen extends StatefulWidget {
  final DeliveryRequest request;

  TrackingScreen({required this.request});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  );
  final LocationService _locationService = LocationService();
  GeoPoint? _driverLocation;

  @override
  void initState() {
    super.initState();
    _locationService.getLocationStream().listen((position) async {
      setState(() {
        _driverLocation = GeoPoint(latitude: position.latitude, longitude: position.longitude);
      });
      if (widget.request.driverId != null) {
        await FirestoreService().updateUserLocation(
          widget.request.driverId!,
          GeoPoint(position.latitude, position.longitude),
          GeoFlutterFire().point(latitude: position.latitude, longitude: position.longitude).hash,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read(authServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Track Delivery')),
      body: Column(
        children: [
          Expanded(
            child: _driverLocation == null
                ? Center(child: CircularProgressIndicator())
                : OSMFlutter(
                    controller: _mapController,
                    trackMyPosition: false,
                    mapIsLoading: Center(child: CircularProgressIndicator()),
                    onMapIsReady: () async {
                      await _mapController.setCenter(_driverLocation!);
                      await _mapController.setZoom(zoomLevel: 15);
                      await _mapController.addMarker(
                        _driverLocation!,
                        markerIcon: MarkerIcon(icon: Icon(Icons.location_pin, color: Colors.red)),
                      );
                    },
                  ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirestoreService()._firestore.collection('requests').doc(widget.request.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              final status = snapshot.data!['status'] ?? 'pending';
              return Column(
                children: [
                  Text('Status: $status'),
                  if (authService.getCurrentUser().then((user) => user?.id == widget.request.driverId) == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => FirestoreService().updateRequestStatus(widget.request.id, 'en_route'),
                          child: Text('Start Delivery'),
                        ),
                        ElevatedButton(
                          onPressed: () => FirestoreService().updateRequestStatus(widget.request.id, 'delivered'),
                          child: Text('Complete'),
                        ),
                      ],
                    ),
                  if (authService.getCurrentUser().then((user) => user?.id == widget.request.customerId && status == 'delivered') == true)
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.request.driverId != null) {
                          await FirestoreService().rateUser(widget.request.driverId!, 5.0);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Confirm and Rate'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}