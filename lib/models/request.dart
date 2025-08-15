class DeliveryRequest {
  final String id;
  final String customerId;
  final String restaurantName;
  final String orderDetails;
  final double estimatedCost;
  final double offerAmount;
  final String deliveryAddress;
  final String status; // pending, bidding, accepted, en_route, delivered
  final String? driverId;

  DeliveryRequest({
    required this.id,
    required this.customerId,
    required this.restaurantName,
    required this.orderDetails,
    required this.estimatedCost,
    required this.offerAmount,
    required this.deliveryAddress,
    this.status = 'pending',
    this.driverId,
  });

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

  factory DeliveryRequest.fromMap(Map<String, dynamic> map) => DeliveryRequest(
        id: map['id'],
        customerId: map['customerId'],
        restaurantName: map['restaurantName'],
        orderDetails: map['orderDetails'],
        estimatedCost: map['estimatedCost'],
        offerAmount: map['offerAmount'],
        deliveryAddress: map['deliveryAddress'],
        status: map['status'],
        driverId: map['driverId'],
      );
}
