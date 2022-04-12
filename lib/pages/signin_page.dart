import 'package:flutter/material.dart';
import 'package:flutter_chat_app/blocs/signin_bloc.dart';
import 'package:flutter_chat_app/event.dart';

class SignInPage extends StatelessWidget {
  final _bloc = SignInBloc();

  SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
        child: Card(
          margin:
              const EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Sign in with...",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [Text("Sign in with Google")],
                  ),
                  onPressed: () => _bloc.inEvent.add(
                    SignInGoogleEvent(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
