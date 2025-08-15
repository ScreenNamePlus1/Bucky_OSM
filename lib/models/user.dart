import 'package:latlong2/latlong.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool isDriver;
  final GeoPoint? location; // From existing repo (for GeoFire)
  final String? geohash; // From existing repo
  List<LatLng>? deliveryArea; // Added: Polygon points for delivery area

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isDriver,
    this.location,
    this.geohash,
    this.deliveryArea,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isDriver: data['isDriver'] ?? false,
      location: data['location'] as GeoPoint?,
      geohash: data['geohash'] as String?,
      deliveryArea: (data['deliveryArea'] as List<dynamic>?)?.map((p) {
        return LatLng(p['lat'], p['lng']);
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isDriver': isDriver,
      'location': location,
      'geohash': geohash,
      'deliveryArea': deliveryArea?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    };
  }
}