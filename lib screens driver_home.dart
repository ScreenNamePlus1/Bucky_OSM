import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/request.dart';
import 'tracking.dart';
import 'package:uuid/uuid.dart';

class DriverHomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService()._auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<DeliveryRequest>>(
        stream: _firestoreService.getRequests((await AuthService().getCurrentUser())!.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final requests = snapshot.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ListTile(
                title: Text('${request.restaurantName}: \$${request.offerAmount}'),
                subtitle: Text('Est. Cost: \$${request.estimatedCost} | ${request.status}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final driverId = AuthService()._auth.currentUser!.uid;
                    final bid = Bid(
                      id: Uuid().v4(),
                      requestId: request.id,
                      driverId: driverId,
                      counterOffer: request.offerAmount, // Accept as-is or modify for counter
                    );
                    await _firestoreService.placeBid(bid);
                    if (request.status == 'accepted' && request.driverId == driverId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrackingScreen(request: request)),
                      );
                    }
                  },
                  child: Text('Bid'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
