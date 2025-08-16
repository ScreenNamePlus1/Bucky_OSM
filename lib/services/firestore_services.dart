import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:latlong2/latlong.dart';
import '../models/user.dart';
import '../models/bid.dart';
import '../models/request.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeoFlutterFire _geo = GeoFlutterFire();

  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserLocation(String userId, GeoPoint location, String geohash) async {
    await _firestore.collection('users').doc(userId).update({
      'location': location,
      'geohash': geohash,
    });
  }

  Future<void> createRequest(Request request) async {
    await _firestore.collection('requests').doc(request.id).set(request.toMap());
  }

  Stream<List<Request>> getNearbyRequests(GeoPoint center, double radiusKm) {
    return _geo
        .collection(collectionRef: _firestore.collection('requests'))
        .within(center: center, radius: radiusKm, field: 'pickupLocation')
        .map((docs) => docs.map((doc) => Request.fromMap(doc.data())).toList());
  }

  Future<void> updateDriverDeliveryArea(String userId, List<LatLng> area) async {
    await _firestore.collection('users').doc(userId).update({
      'deliveryArea': area.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    });
  }

  Future<List<LatLng>?> getDriverDeliveryArea(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data()?['deliveryArea'] as List<dynamic>?;
    return data?.map((p) => LatLng(p['lat'], p['lng'])).toList();
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({'status': status});
  }

  Future<void> rateUser(String userId, double rating) async {
    await _firestore.collection('users').doc(userId).update({
      'rating': FieldValue.increment(rating),
      'ratingCount': FieldValue.increment(1),
    });
  }
}
