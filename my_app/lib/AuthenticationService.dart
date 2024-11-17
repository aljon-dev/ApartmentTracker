import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User signed in: ${userCredential.user?.uid}"); // Debug print
      return userCredential;
    } catch (e) {
      print("Sign in error: $e"); // Debug print
      rethrow;
    }
  }

  Future<String?> verifyPhone(String phoneNumber) async {
    try {
      print("Starting phone verification for: $phoneNumber"); // Debug print
      String? verificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Auto verification completed"); // Debug print
          await _auth.currentUser?.updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}"); // Debug print
          throw Exception(e.message);
        },
        codeSent: (String verId, int? resendToken) {
          print("Verification code sent"); // Debug print
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          print("Auto retrieval timeout"); // Debug print
          verificationId = verId;
        },
      );
      
      return verificationId;
    } catch (e) {
      print("Phone verification error: $e"); // Debug print
      rethrow;
    }
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      await _auth.currentUser?.updatePhoneNumber(credential);
      
      await _firestore
          .collection('tenants')
          .doc(_auth.currentUser?.uid)
          .update({'phoneVerified': true});
          
      return true;
    } catch (e) {
      print("OTP verification error: $e"); // Debug print
      return false;
    }
  }
}