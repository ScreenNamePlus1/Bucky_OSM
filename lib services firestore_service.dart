import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Existing methods, e.g., for user creation/fetching...
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

  // Added: Update driver's delivery area
  Future<void> updateDriverDeliveryArea(String userId, List<LatLng> area) async {
    await _firestore.collection('users').doc(userId).update({
      'deliveryArea': area.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    });
  }

  // Added: Get driver's delivery area
  Future<List<LatLng>?> getDriverDeliveryArea(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data()?['deliveryArea'] as List<dynamic>?;
    return data?.map((p) => LatLng(p['lat'], p['lng'])).toList();
  }

  // Add other existing services...
}