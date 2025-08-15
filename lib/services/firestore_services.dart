import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:latlong2/latlong.dart';
import '../models/user.dart';
import '../models/bid.dart';
import '../models/request.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeoFlutterFire _geo = GeoFlutterFire();

  // Existing user methods
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Existing GeoFire methods (assumed from repo)
  Future<void> updateUserLocation(String userId, GeoPoint location, String geohash) async {
    await _firestore.collection('users').doc(userId).update({
      'location': location,
      'geohash': geohash,
    });
  }

  // Existing request/bid methods (simplified, add your actual implementations)
  Future<void> createRequest(Request request) async {
    await _firestore.collection('requests').doc(request.id).set(request.toMap());
  }

  Stream<List<Request>> getNearbyRequests(GeoPoint center, double radiusKm) {
    return _geo
        .collection(collectionRef: _firestore.collection('requests'))
        .within(center: center, radius: radiusKm, field: 'location')
        .map((docs) => docs.map((doc) => Request.fromMap(doc.data(), doc.id)).toList());
  }

  // Added: Delivery area methods
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
}