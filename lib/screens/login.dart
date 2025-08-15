import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'customer_home.dart';
import 'driver_home.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local Delivery')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final user = await _authService.signInWithPhone(_phoneController.text, 'customer');
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
                      );
                    }
                  },
                  child: Text('Login as Customer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    final user = await _authService.signInWithPhone(_phoneController.text, 'driver');
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => DriverHomeScreen()),
                      );
                    }
                  },
                  child: Text('Login as Driver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
