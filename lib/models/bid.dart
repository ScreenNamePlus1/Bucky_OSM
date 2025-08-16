class Bid {
  final String id;
  final String requestId;
  final String driverId;
  final double counterOffer;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  Bid({
    required this.id,
    required this.requestId,
    required this.driverId,
    required this.counterOffer,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'requestId': requestId,
        'driverId': driverId,
        'counterOffer': counterOffer,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bid.fromMap(Map<String, dynamic> map) => Bid(
        id: map['id'],
        requestId: map['requestId'],
        driverId: map['driverId'],
        counterOffer: map['counterOffer'],
        status: map['status'],
        createdAt: DateTime.parse(map['createdAt']),
      );
}