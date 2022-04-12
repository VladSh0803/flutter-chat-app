import 'package:flutter/material.dart';
import 'package:flutter_chat_app/blocs/addcontact_bloc.dart';
import 'package:flutter_chat_app/event.dart';

class AddContactPage extends StatefulWidget {
  final String uid;
  const AddContactPage({Key? key, required this.uid}) : super(key: key);

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  late final _bloc = AddContactBloc(uid: widget.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _bloc.emailController,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _bloc.inEvent.add(
                AddContactEvent(context),
              ),
              child: const Text('Add new contact'),
            ),
          ],
        ),
      ),
    );
  }
}
