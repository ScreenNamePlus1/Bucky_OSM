import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';
import '../models/bid.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Post a request
  Future<void> postRequest(DeliveryRequest request) async {
    await _firestore.collection('requests').doc(request.id).set(request.toMap());
  }

  // Get requests for drivers (nearby, based on simple filter)
  Stream<List<DeliveryRequest>> getRequests(String driverId) {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryRequest.fromMap(doc.data()))
            .toList());
  }

  // Place a bid
  Future<void> placeBid(Bid bid) async {
    await _firestore.collection('bids').doc(bid.id).set(bid.toMap());
  }

  // Get bids for a request
  Stream<List<Bid>> getBids(String requestId) {
    return _firestore
        .collection('bids')
        .where('requestId', isEqualTo: requestId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bid.fromMap(doc.data())).toList());
  }

  // Accept a bid
  Future<void> acceptBid(String bidId, String requestId, String driverId) async {
    await _firestore.collection('bids').doc(bidId).update({'status': 'accepted'});
    await _firestore
        .collection('requests')
        .doc(requestId)
        .update({'status': 'accepted', 'driverId': driverId});
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({'status': status});
  }

  // Rate user
  Future<void> rateUser(String userId, double rating) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final user = AppUser.fromMap(doc.data()!);
    final newRating = (user.rating * user.completedJobs + rating) / (user.completedJobs + 1);
    await _firestore.collection('users').doc(userId).update({
      'rating': newRating,
      'completedJobs': user.completedJobs + 1,
    });
  }
}
