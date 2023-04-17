import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Components/my_component.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'utils/fire_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
          Widget>[
        buildAppName(),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
        Container(
            width: 320,
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 4),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 32)),
                const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ],
            )),
        Container(
          width: 320,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Form(
                          key: _registerFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Username',
                                  style: TextStyle(fontSize: 16)),
                              TextFormField(
                                controller: _nameTextController,
                                focusNode: _focusName,
                                // The validator receives the text that the user has entered.
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter username',
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 2.0)),
                                    isDense: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4)),
                              const Text('Email',
                                  style: TextStyle(fontSize: 16)),
                              TextFormField(
                                controller: _emailTextController,
                                focusNode: _focusEmail,
                                // The validator receives the text that the user has entered.
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter Email',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2.0),
                                    ),
                                    isDense: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4)),
                              const Text('Password',
                                  style: TextStyle(fontSize: 16)),
                              TextFormField(
                                controller: _passwordTextController,
                                focusNode: _focusPassword,
                                // The validator receives the text that the user has entered.
                                obscureText: true,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter password',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2.0),
                                    ),
                                    isDense: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black),
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(150, 40)),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                      ),
                                      onPressed: ()  async {
                                        setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        User? user = await FireAuth
                                            .registerUsingEmailPassword(
                                          name: _nameTextController.text,
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          if(context.mounted) context.go('/users/${user.uid}');
                                        }
                                      }},
                                      child: const Text('Register'),
                                    ),
                                  )),
                            ],
                          ))
                    ],
                  ))),
        )
      ]),
    ));
  }
}
