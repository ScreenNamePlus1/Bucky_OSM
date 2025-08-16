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
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
        '/login': (_) => const LoginScreen(),
        '/customer': (_) => const CustomerHome(),
        '/driver': (_) => const DriverHomeScreen(),
        '/request': (_) => const RequestForm(),
        '/bid': (_) => const BidForm(),
        '/bids': (_) => const BidSelectionScreen(),
        '/tracking': (_) => const TrackingScreen(),
      },
    );
  }
}