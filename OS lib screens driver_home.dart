import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../widgets/delivery_area_editor.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Home')),
      body: Column(
        children: [
          // Delivery area editor
          SizedBox(
            height: 300, // Fixed height for map, adjust as needed
            child: DeliveryAreaEditor(),
          ),
          // Existing request feed (assumed from repo)
          Expanded(
            child: StreamBuilder<List<Request>>(
              stream: firestore.getNearbyRequests(
                appState.currentUser!.location!,
                10.0, // 10km radius, adjust as needed
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading requests'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snapshot.data!;
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return ListTile(
                      title: Text('Request ${request.id}'),
                      subtitle: Text('From: ${request.startLocation}'),
                      onTap: () {
                        // Navigate to bid screen or show details
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}