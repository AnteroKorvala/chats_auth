import 'package:chats_register/LogIn.dart';
import 'package:chats_register/Registration.dart';
import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isLoggedIn = true;

  @override
  Widget build(BuildContext context) => isLoggedIn
      ? LogIn(onClickedSignUp: toggle)
      : Registration(onClickedSignIn: toggle);

  void toggle() => setState(() {
    isLoggedIn = !isLoggedIn;
  });
}
