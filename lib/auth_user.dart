import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AuthUser {
  final String uid;
  final String? phoneNumber;
  final String role;

  AuthUser({
    required this.uid,
    required this.phoneNumber,
    required this.role,
  });

  factory AuthUser.fromFirebaseUser(firebase.User user, String role) {
    return AuthUser(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      role: role,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'role': role,
      };

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
        uid: map['uid'] ?? '',
        phoneNumber: map['phoneNumber'],
        role: map['role'] ?? 'customer',
      );
}
