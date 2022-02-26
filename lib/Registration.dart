import 'dart:math';

import 'package:chats_register/Auth.dart';
import 'package:chats_register/LogIn.dart';
import 'package:chats_register/Utils.dart';
import 'package:chats_register/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:localstorage/localstorage.dart';

class Registration extends StatefulWidget {
  const Registration({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  final VoidCallback onClickedSignIn;

  @override
  State<StatefulWidget> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  String imageUrl = 'https://cataas.com/cat?type=:sq&v=' +
      Random().nextInt(10000000).toString();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _avatarGenerator() {}

  Future register() async {
    final LocalStorage storage = LocalStorage('userInfo');
    final _userInfoRef = _database.child('/users/');
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      storage.setItem('userName', _usernameController.text.trim());
      storage.setItem('url', imageUrl.toString().trim());
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then((value) {
        value.user!.updateDisplayName(_usernameController.text.trim());
        value.user!.updatePhotoURL(imageUrl.trim());
        DatabaseReference tempRef = _userInfoRef.push();
        final userID = tempRef.key;

        tempRef.set({
          'uid': value.user!.uid,
          'email': value.user!.email,
          'userName': _usernameController.text.trim(),
          'cat_pic': imageUrl
        });
      });
      print('User info written');
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        const Text('Registration'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: widget.onClickedSignIn,
                            child: const Text('Back')),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Image.asset(
                      'assets/images/chatsLOGO.png',
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('Email'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _emailController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Input Email'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Enter a valid email'
                                : null,
                      ),
                      const SizedBox(height: 4),
                      const Text('Username'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _usernameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Input Username'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (username) =>
                            username != null && username.length < 2
                                ? 'Enter min. 3 characters'
                                : null,
                      ),
                      const SizedBox(height: 4),
                      const Text('Password'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Input password'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != null && value.length < 6
                            ? 'Enter min. 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 4),
                      const Text('Avatar'),
                      const SizedBox(height: 4),
                      CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 80,
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          imageUrl = 'https://cataas.com/cat?type=:sq&v=' +
                              Random().nextInt(10000000).toString();
                        }),
                        child: Text(
                          'Generate Avatar'.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(140, 30)),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: register,
                        child: Text(
                          'Register'.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(140, 30)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
