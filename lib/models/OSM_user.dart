import 'package:cloud_firestore/cloud_firestore.dart';

class OSMUser {
  final String id;
  final GeoPoint location;
  final String geohash;

  OSMUser({
    required this.id,
    required this.location,
    required this.geohash,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'location': location,
        'geohash': geohash,
      };

  factory OSMUser.fromMap(Map<String, dynamic> map) => OSMUser(
        id: map['id'] ?? '',
        location: map['location'] ?? GeoPoint(0.0, 0.0),
        geohash: map['geohash'] ?? '',
      );
}