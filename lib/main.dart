import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
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
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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