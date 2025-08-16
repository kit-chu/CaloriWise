import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;


  Future<String?> signInWithGoogleAndGetFirebaseIdToken() async {
    try {
      // 1. ให้ผู้ใช้เลือกบัญชี Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      // 2. ดึง token จาก Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. สร้าง Credential ให้ Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. ล็อกอินกับ Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // 5. ดึง Firebase ID Token พร้อมใช้งาน
      final String? firebaseIdToken = await userCredential.user?.getIdToken(true);

      return firebaseIdToken;

    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }



  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // รับ current user
  GoogleSignInAccount? get currentUser => _currentUser;

  // Auth state stream
  Stream<GoogleSignInAccount?> get authStateChanges => googleSignIn.onCurrentUserChanged;
}