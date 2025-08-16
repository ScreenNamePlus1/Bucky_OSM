class Bid {
  final String id;
  final String requestId;
  final String driverId;
  final double counterOffer;
  final String status;
  final DateTime timestamp;

  Bid({
    required this.id,
    required this.requestId,
    required this.driverId,
    required double counterOffer,
    this.status = 'pending',
    required this.timestamp,
  }) : counterOffer = counterOffer <= 0 ? throw Exception('Counter offer must be positive') : counterOffer;

  Map<String, dynamic> toMap() => {
        'id': id,
        'requestId': requestId,
        'driverId': driverId,
        'counterOffer': counterOffer,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Bid.fromMap(Map<String, dynamic> map) => Bid(
        id: map['id'] ?? '',
        requestId: map['requestId'] ?? '',
        driverId: map['driverId'] ?? '',
        counterOffer: (map['counterOffer'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'pending',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );
}