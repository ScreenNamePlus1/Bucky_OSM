import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> signInWithPhone(String phone, String role, String smsCode, String verificationId) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final appUser = AppUser(id: user.uid, role: role);
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        return appUser;
      }
    } catch (e) {
      print('Auth error: $e');
    }
    return null;
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