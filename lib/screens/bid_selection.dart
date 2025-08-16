import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';

class BidSelectionScreen extends StatelessWidget {
  final String requestId;

  BidSelectionScreen({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Driver')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('requestId', isEqualTo: requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final bids = snapshot.data!.docs.map((doc) => Bid.fromMap(doc.data() as Map<String, dynamic>)).toList();
          if (bids.isEmpty) {
            return Center(child: Text('No bids available'));
          }
          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              return ListTile(
                title: Text('Driver: ${bid.driverId} - Amount: \$${bid.counterOffer}'),
                subtitle: Text('Status: ${bid.status}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Update status to accepted
                    FirebaseFirestore.instance.collection('bids').doc(bid.id).update({'status': 'accepted'});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver selected')));
                  },
                  child: Text('Select'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}