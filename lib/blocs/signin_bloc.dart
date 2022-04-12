import 'package:flutter/material.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_bloc.dart';

class SignInBloc extends BaseBloc {
  @override
  void mapEventToState(Event event) {
    switch (event.runtimeType) {
      case SignInGoogleEvent:
        event as SignInGoogleEvent;
        SharedPreferences.getInstance().then(
          (prefs) => AuthService.signInGoogle().then(
            (uid) => uid != null
                ? Navigator.pushReplacement(
                    event.context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        uid: uid,
                      ),
                    ),
                  )
                : null,
          ),
        );
        break;
    }
  }
}
