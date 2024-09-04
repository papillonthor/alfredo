import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authManagerProvider = FutureProvider<String?>((ref) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await user.getIdToken(true); // 강제 토큰 갱신
  }
  return null;
});
