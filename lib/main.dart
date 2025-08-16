import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'screens/login.dart';
import 'screens/customer_home.dart';
import 'screens/driver_home.dart';
import 'screens/request_form.dart';
import 'screens/bid_form.dart';
import 'screens/bid_selection.dart';
import 'screens/tracking.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Intl.defaultLocale = 'en_US';

  FlutterError.onError = (details) {
    print('Global error: $details');
    // Log to Firebase or Sentry
  };

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Local Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/customer': (_) => CustomerHome(),
        '/driver': (_) => DriverHomeScreen(),
        '/request': (_) => RequestForm(),
        '/bid': (_) => BidForm(),
        '/bids': (_) => BidSelectionScreen(
              requestId: ModalRoute.of(_)!.settings.arguments as String,
            ),
        '/tracking': (_) => TrackingScreen(
              request: ModalRoute.of(_)!.settings.arguments as DeliveryRequest,
            ),
      },
    );
  }
}