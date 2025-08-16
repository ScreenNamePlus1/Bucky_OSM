import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import 'customer_home.dart';
  import 'driver_home.dart';

  class LoginScreen extends StatefulWidget {
    @override
    _LoginScreenState createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final AuthService _authService = AuthService();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _otpController = TextEditingController();
    String? _verificationId;
    bool _isOtpSent = false;
    String _role = 'customer';

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
                decoration: InputDecoration(labelText: 'Phone Number (e.g., +1234567890)'),
                keyboardType: TextInputType.phone,
              ),
              if (_isOtpSent) ...[
                SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(labelText: 'Enter OTP'),
                  keyboardType: TextInputType.number,
                ),
              ],
              SizedBox(height: 20),
              if (!_isOtpSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _role,
                      items: [
                        DropdownMenuItem(value: 'customer', child: Text('Customer')),
                        DropdownMenuItem(value: 'driver', child: Text('Driver')),
                      ],
                      onChanged: (value) {
                        setState(() => _role = value!);
                      },
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a phone number')),
                          );
                          return;
                        }
                        await _authService.verifyPhoneNumber(
                          context,
                          phone,
                          _role,
                          (verificationId) {
                            setState(() {
                              _verificationId = verificationId;
                              _isOtpSent = true;
                            });
                          },
                        );
                      },
                      child: Text('Send OTP'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    final otp = _otpController.text.trim();
                    if (otp.isEmpty || _verificationId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter the OTP')),
                      );
                      return;
                    }
                    final user = await _authService.signInWithPhoneAndOtp(
                      context,
                      _verificationId!,
                      otp,
                      _role,
                    );
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _role == 'customer' ? CustomerHome() : DriverHomeScreen(),
                        ),
                      );
                    }
                  },
                  child: Text('Verify OTP'),
                ),
            ],
          ),
        ),
      );
    }

    @override
    void dispose() {
      _phoneController.dispose();
      _otpController.dispose();
      super.dispose();
    }
  }