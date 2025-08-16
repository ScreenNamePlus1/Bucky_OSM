import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  final String role;
  GeoPoint? location;
  String? geohash;
  double? rating;
  int? ratingCount;

  AppUser({
    required this.id,
    required this.role,
    this.location,
    this.geohash,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role,
        'location': location,
        'geohash': geohash,
        'rating': rating,
        'ratingCount': ratingCount,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] ?? '',
        role: map['role'] ?? 'customer',
        location: map['location'] != null
            ? GeoPoint(map['location']['latitude'], map['location']['longitude'])
            : null,
        geohash: map['geohash'],
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
      );
}
