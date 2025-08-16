import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/request.dart';
import '../providers.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class TrackingScreen extends ConsumerStatefulWidget {
  final DeliveryRequest request;

  const TrackingScreen({required this.request, super.key});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final MapController _mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  );
  GeoPoint? _driverLocation;

  @override
  void initState() {
    super.initState();
    ref.read(locationServiceProvider).getLocationStream().listen((position) async {
      setState(() {
        _driverLocation = GeoPoint(latitude: position.latitude, longitude: position.longitude);
      });
      if (widget.request.driverId != null) {
        await ref.read(firestoreServiceProvider).updateUserLocation(
              widget.request.driverId!,
              GeoPoint(position.latitude, position.longitude),
              GeoFlutterFire().point(latitude: position.latitude, longitude: position.longitude).hash,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Delivery')),
      body: Column(
        children: [
          Expanded(
            child: _driverLocation == null
                ? const Center(child: CircularProgressIndicator())
                : OSMFlutter(
                    controller: _mapController,
                    trackMyPosition: false,
                    mapIsLoading: const Center(child: CircularProgressIndicator()),
                    onMapIsReady: () async {
                      await _mapController.setCenter(_driverLocation!);
                      await _mapController.setZoom(zoomLevel: 15);
                      await _mapController.addMarker(
                        _driverLocation!,
                        markerIcon: const MarkerIcon(icon: Icon(Icons.location_pin, color: Colors.red)),
                      );
                    },
                  ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: ref.read(firestoreServiceProvider)._firestore.collection('requests').doc(widget.request.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final status = snapshot.data!['status'] ?? 'pending';
              return FutureBuilder<AppUser?>(
                future: ref.read(authServiceProvider).getCurrentUser(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();
                  final user = userSnapshot.data;
                  return Column(
                    children: [
                      Text('Status: $status'),
                      if (user?.id == widget.request.driverId)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => ref.read(firestoreServiceProvider).updateRequestStatus(widget.request.id, 'en_route'),
                              child: const Text('Start Delivery'),
                            ),
                            ElevatedButton(
                              onPressed: () => ref.read(firestoreServiceProvider).updateRequestStatus(widget.request.id, 'delivered'),
                              child: const Text('Complete'),
                            ),
                          ],
                        ),
                      if (user?.id == widget.request.customerId && status == 'delivered')
                        ElevatedButton(
                          onPressed: () async {
                            if (widget.request.driverId != null) {
                              await ref.read(firestoreServiceProvider).rateUser(widget.request.driverId!, 5.0);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Confirm and Rate'),
                        ),
                    ],
                  );
                },
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