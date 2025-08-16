import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login.dart';
import 'screens/customer_home.dart';
import 'screens/driver_home.dart';
import 'screens/request_form.dart';
import 'screens/bid_form.dart';
import 'screens/bid_selection.dart';
import 'screens/tracking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

FlutterError.onError = (details) {
  print('Global error: $details');
  // Log to Firebase or Sentry
};

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
        '/driver': (_) => DriverHome(),
        '/request': (_) => RequestForm(),
        '/bid': (_) => BidForm(),
        '/bids': (_) => BidSelection(),
        '/tracking': (_) => TrackingScreen(),
      },
    );
  }
}