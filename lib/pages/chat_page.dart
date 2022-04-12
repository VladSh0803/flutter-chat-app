import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/blocs/chat_bloc.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/helpful_functions.dart';

class ChatPage extends StatefulWidget {
  final CollectionReference chatRef;
  final String uid;
  final String contactUid;
  const ChatPage(
      {Key? key,
      required this.chatRef,
      required this.uid,
      required this.contactUid})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc(
      uid: widget.uid,
      contactUid: widget.contactUid,
      chatRef: widget.chatRef,
    );
  }

  List<Widget> generateMessageLayout(DocumentSnapshot doc, bool isSender) {
    return [
      Expanded(
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (isSender ? Colors.grey.shade200 : Colors.blue[200]),
              ),
              padding: const EdgeInsets.all(16),
              child: doc['image_url'] == ''
                  ? Text(doc['text'])
                  : InkWell(
                      child: Container(
                        child: Image(
                          image: StaticFunctions.generateImageProvider(
                            doc['image_url'],
                          ),
                          fit: BoxFit.fill,
                        ),
                        height: 150,
                        width: 150,
                        padding: const EdgeInsets.all(5),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ];
  }

  StreamBuilder generateMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _bloc.outChatMessages,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!snapshot.hasData) {
          return const Text('No messages');
        }
        if (snapshot.connectionState == ConnectionState.active) {
          _bloc.inEvent.add(
            MessageViewedEvent(),
          );
          return Expanded(
            child: ListView(
              reverse: true,
              children: snapshot.data!.docs
                  .map<Widget>(
                    (doc) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: doc['sender_uid'] == _bloc.uid
                            ? generateMessageLayout(doc, true)
                            : generateMessageLayout(doc, false),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }
        return const Expanded(
          child: Text('Loading...'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        flexibleSpace: SafeArea(
          child: StreamBuilder(
            stream: _bloc.outUserInfo,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot?> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong!');
              }
              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text('Document does not exist!');
              }
              if (snapshot.connectionState == ConnectionState.active) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Row(
                  children: [
                    IconButton(
                      onPressed: () => _bloc.inEvent.add(
                        GoBackEvent(context),
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    CircleAvatar(
                      backgroundImage: StaticFunctions.generateImageProvider(
                        data['photoURL'],
                      ),
                      maxRadius: 20,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(data['name']),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            generateMessageList(),
            const Divider(
              height: 1,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _bloc.inEvent.add(
                      SendImageEvent(),
                    ),
                    icon: const Icon(Icons.photo_camera),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _bloc.textController,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Send a message"),
                    ),
                  ),
                  StreamBuilder(
                    stream: _bloc.outIsWriting,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasData && snapshot.data!) {
                        return Ink(
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _bloc.inEvent.add(
                              SendMessageEvent(),
                            ),
                          ),
                        );
                      }
                      return IconTheme(
                        data: IconThemeData(
                            color: Theme.of(context).disabledColor),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _bloc.inEvent.add(
                            SendMessageEvent(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
