import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

abstract class Event {}

class SendMessageEvent extends Event {}

class SendImageEvent extends Event {}

class MessageViewedEvent extends Event {}

class GoToPageEvent extends Event {
  final BuildContext context;
  GoToPageEvent(this.context);
}

class GoToAddNewContactPageEvent extends GoToPageEvent {
  GoToAddNewContactPageEvent(BuildContext context) : super(context);
}

class GoToSignInPageEvent extends GoToPageEvent {
  GoToSignInPageEvent(BuildContext context) : super(context);
}

class GoToChatPageEvent extends GoToPageEvent {
  final QueryDocumentSnapshot chatSnapshot;
  GoToChatPageEvent(BuildContext context, {required this.chatSnapshot})
      : super(context);
}

class SignInGoogleEvent extends GoToPageEvent {
  SignInGoogleEvent(BuildContext context) : super(context);
}

class GoBackEvent extends GoToPageEvent {
  GoBackEvent(BuildContext context) : super(context);
}

class AddContactEvent extends GoToPageEvent {
  AddContactEvent(BuildContext context) : super(context);
}
