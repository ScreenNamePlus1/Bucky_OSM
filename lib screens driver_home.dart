import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../widgets/delivery_area_editor.dart';  // Added import
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  List<LatLng>? _deliveryArea;  // Added: To hold loaded area

  @override
  void initState() {
    super.initState();
    _loadDeliveryArea();  // Added: Load on init
  }

  Future<void> _loadDeliveryArea() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final firestore = FirestoreService();
    _deliveryArea = await firestore.getDriverDeliveryArea(appState.currentUser!.id);
    setState(() {});  // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    // Existing UI, e.g., for bids/requests...
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Home')),
      body: Column(
        children: [
          // Added: The delivery area editor widget
          Expanded(
            child: DeliveryAreaEditor(
              apiKey: 'YOUR_GOOGLE_API_KEY',  // Replace with your key
              initialArea: _deliveryArea,
            ),
          ),
          // Add your existing widgets, e.g., list of delivery requests...
        ],
      ),
    );
  }
}