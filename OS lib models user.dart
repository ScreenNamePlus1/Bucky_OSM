import 'package:latlong2/latlong.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool isDriver;
  List<LatLng>? deliveryArea;  // Polygon points for delivery area

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isDriver,
    this.deliveryArea,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isDriver': isDriver,
      'deliveryArea': deliveryArea?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    };
  }
}