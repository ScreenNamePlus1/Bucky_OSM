class AppUser {
  final String id;
  final String role;
  final String? fcmToken; // For notifications

  AppUser({required this.id, required this.role, this.fcmToken});

  Map<String, dynamic> toMap() => {'id': id, 'role': role, 'fcmToken': fcmToken};

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'],
        role: map['role'],
        fcmToken: map['fcmToken'],
      );
}