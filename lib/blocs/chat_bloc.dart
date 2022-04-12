import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/services/db.dart';

import 'base_bloc.dart';

class ChatBloc extends BaseBloc {
  final String uid;
  final String contactUid;
  final CollectionReference chatRef;
  bool isWriting = false;

  final TextEditingController textController = TextEditingController();
  final StreamController<bool> _isWritingController = StreamController<bool>();

  Sink<bool> get inIsWriting => _isWritingController.sink;

  Stream<DocumentSnapshot?> get outUserInfo =>
      DBService.getUserInfoByUid(contactUid);
  Stream<QuerySnapshot> get outChatMessages => DBService.getMessages(chatRef);
  Stream<bool> get outIsWriting => _isWritingController.stream;

  ChatBloc({required this.uid, required this.contactUid, required this.chatRef})
      : super() {
    textController.addListener(
      () {
        inIsWriting.add(textController.text.trim().isNotEmpty);
        isWriting = textController.text.isNotEmpty;
      },
    );
  }

  @override
  void mapEventToState(Event event) {
    switch (event.runtimeType) {
      case GoBackEvent:
        event as GoBackEvent;
        Navigator.pop(event.context);
        break;
      case SendMessageEvent:
        event as SendMessageEvent;
        if (isWriting) {
          DBService.sendMessage(
            chatRef,
            textController.text.trim(),
            uid,
          );
          textController.clear();
        }
        break;
      case SendImageEvent:
        event as SendImageEvent;
        DBService.sendImage(
          uid,
        ).then(
          (url) => url != null
              ? DBService.sendMessage(
                  chatRef,
                  '',
                  uid,
                  imageURL: url,
                )
              : null,
        );
        break;
      case MessageViewedEvent:
        DBService.sendMessageViewed(chatRef);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    _isWritingController.close();
  }
}
