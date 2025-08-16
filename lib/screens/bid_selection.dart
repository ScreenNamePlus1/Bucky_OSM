import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';
import '../models/request.dart';
import '../providers.dart';

class BidSelectionScreen extends ConsumerStatefulWidget {
  const BidSelectionScreen({super.key});

  @override
  _BidSelectionScreenState createState() => _BidSelectionScreenState();
}

class _BidSelectionScreenState extends ConsumerState<BidSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final requestId = args['requestId'] as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Driver')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('requestId', isEqualTo: requestId)
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bids available'));
          }
          final bids = snapshot.data!.docs
              .map((doc) => Bid.fromMap(doc.data()))
              .toList()
            ..sort((a, b) => a.counterOffer.compareTo(b.counterOffer));
          if (bids.isEmpty) {
            return const Center(child: Text('No bids available'));
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
                    await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .update({'driverId': bid.driverId, 'status': 'accepted'});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Driver selected')),
                    );
                    Navigator.pushNamed(
                      context,
                      '/tracking',
                      arguments: {'request': Request.fromMap(await FirebaseFirestore.instance.collection('requests').doc(requestId).get().then((doc) => doc.data()!))},
                    );
                  },
                  child: const Text('Select'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
