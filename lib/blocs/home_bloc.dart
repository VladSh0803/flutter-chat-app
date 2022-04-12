import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/pages/addcontact_page.dart';
import 'package:flutter_chat_app/pages/chat_page.dart';
import 'package:flutter_chat_app/pages/signin_page.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:flutter_chat_app/services/db.dart';

import 'base_bloc.dart';

class HomeBloc extends BaseBloc {
  final String uid;

  Stream<DocumentSnapshot?> get outUserInfo => DBService.getUserInfoByUid(uid);
  Stream<QuerySnapshot> get outUserChats => DBService.getUserChats(uid);

  Stream<QuerySnapshot> outUserInfoExceptCurrent(List<String> uids) {
    return DBService.getUserInfoExceptCurrent(uids, uid);
  }

  HomeBloc({required this.uid}) : super();

  @override
  void mapEventToState(Event event) {
    switch (event.runtimeType) {
      case GoToAddNewContactPageEvent:
        Navigator.push(
          (event as GoToAddNewContactPageEvent).context,
          MaterialPageRoute(
            builder: (context) => AddContactPage(uid: uid),
          ),
        );
        break;
      case GoToSignInPageEvent:
        event as GoToChatPageEvent;
        AuthService.logout().then(
          (_) => Navigator.pushReplacement(
            event.context,
            MaterialPageRoute(
              builder: (context) => SignInPage(),
            ),
          ),
        );
        break;
      case GoToChatPageEvent:
        event as GoToChatPageEvent;
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatRef: event.chatSnapshot.reference.collection('messages'),
              uid: uid,
              contactUid: event.chatSnapshot['contacts'][0] == uid
                  ? event.chatSnapshot['contacts'][1]
                  : event.chatSnapshot['contacts'][0],
            ),
          ),
        );
        break;
    }
  }
}
