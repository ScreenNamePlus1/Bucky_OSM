import 'package:flutter_test/flutter_test.dart';
import '../lib/models/bid.dart';

void main() {
  test('Bid toMap/fromMap consistency', () {
    final timestamp = DateTime.now();
    final bid = Bid(
      id: '1',
      requestId: 'req1',
      driverId: 'drv1',
      counterOffer: 10.0,
      status: 'pending',
      timestamp: timestamp,
    );
    final map = bid.toMap();
    final newBid = Bid.fromMap(map);
    expect(newBid.id, bid.id);
    expect(newBid.requestId, bid.requestId);
    expect(newBid.driverId, bid.driverId);
    expect(newBid.counterOffer, bid.counterOffer);
    expect(newBid.status, bid.status);
    expect(newBid.timestamp, bid.timestamp);
  });

  test('Bid throws on invalid counterOffer', () {
    expect(
      () => Bid(
        id: '1',
        requestId: 'req1',
        driverId: 'drv1',
        counterOffer: -1.0,
        timestamp: DateTime.now(),
      ),
      throwsException,
    );
    expect(
      () => Bid(
        id: '1',
        requestId: 'req1',
        driverId: 'drv1',
        counterOffer: 4.99,
        timestamp: DateTime.now(),
      ),
      throwsException,
    );
  });
}
