import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Timer? _tokenRefreshTimer;

  AuthService() {
    startTokenRefreshTimer();
  }

  void startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer =
        Timer.periodic(const Duration(minutes: 50), (timer) async {
      await getIdToken(forceRefresh: true);
    });
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      startTokenRefreshTimer();
      final token = await userCredential.user?.getIdToken();
      return {
        'userCredential': userCredential,
        'token': token,
      };
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken(forceRefresh);
      print('Token refreshed: $token');
      return token;
    }
    return null;
  }

  void dispose() {
    _tokenRefreshTimer?.cancel();
  }
}
