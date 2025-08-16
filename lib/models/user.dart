class AppUser {
   String id;
  final String role;

  AppUser({required this.id, required this.role});

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] ?? '',
        role: map['role'] ?? 'customer',
      );
}