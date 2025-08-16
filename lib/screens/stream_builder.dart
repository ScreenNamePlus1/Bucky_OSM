StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('bids').where('requestId', isEqualTo: requestId).snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final bid = Bid.fromMap(snapshot.data!.docs[index].data());
          return ListTile(title: Text('Bid: \$${bid.counterOffer} - Status: ${bid.status}'));
        },
      );
    }
    return CircularProgressIndicator();
  },
);