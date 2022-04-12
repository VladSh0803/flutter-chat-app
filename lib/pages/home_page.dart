import 'package:flutter/material.dart';
import 'package:flutter_chat_app/blocs/home_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/event.dart';
import 'package:flutter_chat_app/helpful_functions.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            StreamBuilder(
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
                  return UserAccountsDrawerHeader(
                    accountName: Text('${data['name']}'),
                    accountEmail: Text('${data['email']}'),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: StaticFunctions.generateImageProvider(
                        data['photoURL'],
                      ),
                    ),
                  );
                }
                return const Text('Loading...');
              },
            ),
            ListTile(
              title: const Text('Add new contact'),
              leading: const Icon(Icons.add),
              onTap: () => _bloc.inEvent.add(
                GoToAddNewContactPageEvent(context),
              ),
            ),
            ListTile(
              title: const Text('Exit'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => _bloc.inEvent.add(
                GoToSignInPageEvent(context),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text("Chats"),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: _bloc.outUserChats,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> userChatsSnapshot) {
              if (userChatsSnapshot.hasError) {
                return const Text('Something went wrong!');
              }
              // if (!snapshot.hasData) {
              //   return const Text('No contacts');
              // }
              if (userChatsSnapshot.hasData &&
                  userChatsSnapshot.connectionState == ConnectionState.active) {
                return Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: userChatsSnapshot.data!.docs
                        .map<Widget>(
                          (doc) => InkWell(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    child: StreamBuilder(
                                      stream: _bloc.outUserInfoExceptCurrent(
                                        List<String>.from(doc['contacts']),
                                      ),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Something went wrong!');
                                        }
                                        // if (!snapshot.hasData) {
                                        //   return const Text('No contacts');
                                        // }
                                        if (snapshot.hasData &&
                                            snapshot.connectionState ==
                                                ConnectionState.active) {
                                          String contacts =
                                              snapshot.data!.docs[0]['name'];
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: StaticFunctions
                                                  .generateImageProvider(
                                                snapshot.data!.docs[0]
                                                    ['photoURL'],
                                              ),
                                              maxRadius: 20,
                                            ),
                                            title: Text(contacts),
                                            trailing: doc['last_sender_uid'] !=
                                                        _bloc.uid &&
                                                    doc['last_sender_uid'] != ''
                                                ? const Icon(Icons.email)
                                                : const Icon(
                                                    Icons.chevron_right),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _bloc.inEvent.add(
                              GoToChatPageEvent(
                                context,
                                chatSnapshot: doc,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              }
              return const Text('');
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
