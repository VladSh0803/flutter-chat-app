import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:flutter_chat_app/pages/signin_page.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences.getInstance().then(
    (prefs) {
      AuthService.prefs = prefs;
      String? uid = AuthService.autoLogin();
      if (uid == null) {
        runApp(
          MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: SignInPage(),
          ),
        );
      } else {
        runApp(
          MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: HomePage(
              uid: uid,
            ),
          ),
        );
      }
    },
  );
}
