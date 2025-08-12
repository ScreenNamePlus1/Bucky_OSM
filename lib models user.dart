import 'package:google_maps_flutter/google_maps_flutter.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool isDriver;
  // Add other existing fields as needed...

  List<LatLng>? deliveryArea;  // Added: Polygon points defining the delivery area

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isDriver,
    this.deliveryArea,
    // Add other params...
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isDriver: data['isDriver'] ?? false,
      deliveryArea: (data['deliveryArea'] as List<dynamic>?)?.map((p) {
        return LatLng(p['lat'], p['lng']);
      }).toList(),
      // Add other fields...
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isDriver': isDriver,
      'deliveryArea': deliveryArea?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      // Add other fields...
    };
  }
}