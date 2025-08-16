import 'package:flutter_test/flutter_test.dart';
import 'bid.dart';

void main() {
  test('Bid toMap/fromMap consistency', () {
    final bid = Bid(id: '1', requestId: 'req1', driverId: 'drv1', counterOffer: 10.0, createdAt: DateTime.now());
    final map = bid.toMap();
    final newBid = Bid.fromMap(map);
    expect(newBid.counterOffer, bid.counterOffer);
  });
}