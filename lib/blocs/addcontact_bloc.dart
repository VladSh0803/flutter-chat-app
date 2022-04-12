import 'package:flutter/material.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/pages/chat_page.dart';
import 'package:flutter_chat_app/services/db.dart';

import 'base_bloc.dart';

class AddContactBloc extends BaseBloc {
  final String uid;
  final TextEditingController emailController = TextEditingController();

  AddContactBloc({required this.uid}) : super();

  @override
  void mapEventToState(Event event) {
    switch (event.runtimeType) {
      case AddContactEvent:
        event as AddContactEvent;
        DBService.getUserUidByEmail(
          emailController.text,
        ).then(
          (contactUid) => contactUid == null
              ? null
              : DBService.getChat(
                  [uid, contactUid],
                ).then(
                  (doc) => Navigator.push(
                    event.context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatRef: DBService.getChatMessages(doc),
                        uid: uid,
                        contactUid: contactUid,
                      ),
                    ),
                  ),
                ),
        );
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }
}
