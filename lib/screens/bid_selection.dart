import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';

class BidSelectionScreen extends StatefulWidget {
  final String requestId;

  BidSelectionScreen({required this.requestId});

  @override
  _BidSelectionScreenState createState() => _BidSelectionScreenState();
}

class _BidSelectionScreenState extends State<BidSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Driver')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('requestId', isEqualTo: widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final bids = snapshot.data!.docs
              .map((doc) => Bid.fromMap(doc.data() as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.counterOffer.compareTo(b.counterOffer));
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
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('bids').doc(bid.id).update({'status': 'accepted'});
                    await FirebaseFirestore.instance.collection('requests').doc(bid.requestId).update({'status': 'accepted'});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver selected')));
                    Navigator.pop(context);
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