import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _secureStorage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  Future<AppUser?> signInWithPhone(String phone, String role, String verificationCode) async {
    try {
      // Step 1: Send verification code (call this first in UI)
      // await _auth.verifyPhoneNumber(...); // Implement full flow in UI

      // Step 2: Verify code
      final credential = PhoneAuthProvider.credential(
        verificationId: 'your_verification_id_from_callback', // From verifyPhoneNumber callback
        smsCode: verificationCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final appUser = AppUser(id: user.uid, role: role);
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        await _secureStorage.write(key: 'user_token', value: await user.getIdToken());
        return appUser;
      }
    } catch (e) {
      print('Auth error: $e');
    }
    return null;
  }

  Future<bool> authenticateWithBiometrics() async {
    return await _localAuth.authenticate(
      localizedReason: 'Authenticate to access secure features',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
}