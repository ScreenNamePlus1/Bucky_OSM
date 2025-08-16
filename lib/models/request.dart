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
      required String restaurantName,
      required String orderDetails,
      required double estimatedCost,
      required double offerAmount,
      required String deliveryAddress,
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
