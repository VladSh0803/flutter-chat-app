import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/services/db.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static late SharedPreferences prefs;
  static final _auth = FirebaseAuth.instance;

  static Future<String?> signInGoogle() async {
    User? user;
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        googleAuthProvider.setCustomParameters(
          {
            'login_hint': 'user@example.com',
          },
        );
        user = (await _auth.signInWithPopup(googleAuthProvider)).user;
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          user = (await _auth.signInWithCredential(credential)).user;
        }
      }
      if (user != null) {
        DBService.addUser(
          user.uid,
          user.displayName!,
          user.email!,
          user.photoURL!,
        );
        await prefs.setString('uid', user.uid);
        return user.uid;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  static String? autoLogin() {
    return prefs.getString('uid');
  }

  static Future<void> logout() async {
    await prefs.remove('uid');
    await _auth.signOut();
  }
}
