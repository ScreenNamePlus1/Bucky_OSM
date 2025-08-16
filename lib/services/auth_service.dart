import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> signInWithPhone(BuildContext context, String phone, String role) async {
  try {
    if (!['customer', 'driver'].contains(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid role selected')),
      );
      return null;
      }
    }
    ```
  - **Code to Insert**:
    ```dart
    Future<void> verifyPhoneNumber(
      BuildContext context,
      String phone,
      String role,
      Function(String) onCodeSent,
    ) async {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            final userCredential = await _auth.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              final appUser = AppUser(id: user.uid, role: role);
              await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
            }
          },
          verificationFailed: (FirebaseAuthException e) {
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
        final credential = PhoneAuthProvider.credential(
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
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
        completer.complete(null);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store verificationId for manual OTP entry (handled in login.dart)
        completer.complete(null); // Will be handled in UI
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout if needed
      },
    );
    return completer.future;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Auth error: $e')),
    );
    return null;
  }
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
Future<void> signOut() async {
  await _auth.signOut();
}