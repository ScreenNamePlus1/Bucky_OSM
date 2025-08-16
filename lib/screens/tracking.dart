  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import 'package:geoflutterfire2/geoflutterfire2.dart';
  import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
  import '../services/location_service.dart';
  import '../services/firestore_service.dart';
  import '../models/request.dart';

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
        await FirestoreService().updateUserLocation(
          widget.request.driverId!,
          GeoPoint(position.latitude, position.longitude),
          GeoFlutterFire().point(latitude: position.latitude, longitude: position.longitude).hash,
        );
      });
    }

    @override
    Widget build(BuildContext context) {
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
                final status = snapshot.data!['status'];
                return Column(
                  children: [
                    Text('Status: $status'),
                    if (AuthService()._auth.currentUser!.uid == widget.request.driverId)
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
                    if (AuthService()._auth.currentUser!.uid == widget.request.customerId && status == 'delivered')
                      ElevatedButton(
                        onPressed: () async {
                          await FirestoreService().rateUser(widget.request.driverId!, 5.0);
                          Navigator.pop(context);
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