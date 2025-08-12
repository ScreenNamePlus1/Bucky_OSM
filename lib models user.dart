class AppUser {
  final String id;
  final String role; // customer, driver
  final double rating;
  final int completedJobs;

  AppUser({
    required this.id,
    required this.role,
    this.rating = 5.0,
    this.completedJobs = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role,
        'rating': rating,
        'completedJobs': completedJobs,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'],
        role: map['role'],
        rating: map['rating'],
        completedJobs: map['completedJobs'],
      );
}
