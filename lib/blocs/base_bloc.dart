import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/event.dart';

abstract class BaseBloc {
  @protected
  final eventController = StreamController<Event>();

  Sink<Event> get inEvent => eventController.sink;

  BaseBloc() {
    eventController.stream.listen(mapEventToState);
  }

  @protected
  void mapEventToState(Event event) {}

  void dispose() {
    eventController.close();
  }
}
