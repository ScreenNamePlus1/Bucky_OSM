import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/bid.dart';

class BidSelectionScreen extends StatelessWidget {
  final String requestId;

  BidSelectionScreen({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Driver')),
      body: StreamBuilder<List<Bid>>(
        stream: FirestoreService().getBids(requestId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final bids = snapshot.data!;
          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              return ListTile(
                title: Text('Driver ID: ${bid.driverId}'),
                subtitle: Text('Offer: \$${bid.counterOffer}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await FirestoreService().acceptBid(bid.id, requestId, bid.driverId);
                    Navigator.pop(context);
                  },
                  child: Text('Accept'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
