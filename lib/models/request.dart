class Request {
  final String id;
  final String customerId;
  final String restaurantName;
  final String orderDetails;
  final double estimatedCost;
  final double offerAmount;
  final String deliveryAddress;
  final String status;
  final String? driverId;

  Request({
    required this.id,
    required this.customerId,
    required String restaurantName,
    required String orderDetails,
    required double estimatedCost,
    required double offerAmount,
    required Striddressng deliveryA,
    this.status = 'pending',
    this.driverId,
  })  : restaurantName = restaurantName.isEmpty ? throw Exception('Restaurant name required') : restaurantName,
        orderDetails = orderDetails.isEmpty ? throw Exception('Order details required') : orderDetails,
        estimatedCost = estimatedCost <= 0 ? throw Exception('Estimated cost must be positive') : estimatedCost,
        offerAmount = offerAmount <= 0 ? throw Exception('Offer amount must be positive') : offerAmount,
        deliveryAddress = deliveryAddress.isEmpty ? throw Exception('Delivery address required') : deliveryAddress;

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerId': customerId,
        'restaurantName': restaurantName,
        'orderDetails': orderDetails,
        'estimatedCost': estimatedCost,
        'offerAmount': offerAmount,
        'deliveryAddress': deliveryAddress,
        'status': status,
        'driverId': driverId,
      };

  factory Request.fromMap(Map<String, dynamic> map) => Request(
        id: map['id'] ?? '',
        customerId: map['customerId'] ?? '',
        restaurantName: map['restaurantName'] ?? '',
        orderDetails: map['orderDetails'] ?? '',
        estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
        offerAmount: (map['offerAmount'] as num?)?.toDouble() ?? 0.0,
        deliveryAddress: map['deliveryAddress'] ?? '',
        status: map['status'] ?? 'pending',
        driverId: map['driverId'],
      );
}