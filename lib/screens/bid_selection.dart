import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';

class BidSelectionScreen extends StatelessWidget {
  final String requestId;

  BidSelectionScreen({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Bid for Request $requestId')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('requestId', isEqualTo: requestId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading bids: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Retry
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final bids = snapshot.data!.docs.map((doc) => Bid.fromMap(doc.data() as Map<String, dynamic>)).toList();
          if (bids.isEmpty) {
            return Center(child: Text('No bids yet'));
          }
          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              return ListTile(
                title: Text('Driver: ${bid.driverId}'),
                subtitle: Text('Amount: \$${bid.counterOffer} - Status: ${bid.status}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Accept bid logic
                    FirebaseFirestore.instance.collection('bids').doc(bid.id).update({'status': 'accepted'});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid accepted')));
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