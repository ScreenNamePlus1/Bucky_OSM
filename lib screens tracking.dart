import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _locationService.getLocationStream().listen((position) {
      setState(() {
        _driverLocation = LatLng(position.latitude, position.longitude);
      });
      // Update driver location in Firestore (for production, use GeoPoint)
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
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _driverLocation!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('driver'),
                        position: _driverLocation!,
                      ),
                    },
                    onMapCreated: (controller) => _mapController = controller,
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
                        await FirestoreService().rateUser(widget.request.driverId!, 5.0); // Example rating
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
}
