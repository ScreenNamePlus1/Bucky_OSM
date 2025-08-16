import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> verifyPhoneNumber(
    BuildContext context,
    String phone,
    String role,
    Function(String) onCodeSent,
  ) async {
    try {
      if (!['customer', 'driver'].contains(role)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid role selected')),
        );
        return;
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (firebase.PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            final appUser = AppUser(id: user.uid, role: role);
            await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
          }
        },
        verificationFailed: (firebase.FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<AppUser?> signInWithPhoneAndOtp(
    BuildContext context,
    String verificationId,
    String smsCode,
    String role,
  ) async {
    try {
      final credential = firebase.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final appUser = AppUser(id: user.uid, role: role);
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        return appUser;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
    }
    return null;
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}