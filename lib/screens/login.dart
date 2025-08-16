import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers.dart';
import '../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  String _role = 'customer';
  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (e.g., +1234567890)'),
              keyboardType: TextInputType.phone,
            ),
            if (_isOtpSent) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            if (!_isOtpSent)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'driver', child: Text('Driver')),
                    ],
                    onChanged: (value) {
                      setState(() => _role = value!);
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final phone = _phoneController.text.trim();
                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a phone number')),
                        );
                        return;
                      }
                      await ref.read(authServiceProvider).verifyPhoneNumber(
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
                    child: const Text('Send OTP'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () async {
                  final otp = _otpController.text.trim();
                  if (otp.isEmpty || _verificationId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter the OTP')),
                    );
                    return;
                  }
                  final user = await ref.read(authServiceProvider).signInWithPhoneAndOtp(
                        context,
                        _verificationId!,
                        otp,
                        _role,
                      );
                  if (user != null) {
                    ref.read(appStateProvider.notifier).setUser(user.id, user.role);
                    Navigator.pushReplacementNamed(
                      context,
                      user.role == 'customer' ? '/customer' : '/driver',
                    );
                  }
                },
                child: const Text('Verify OTP'),
              ),
          ],
        ),
      ),
    );
  }
}