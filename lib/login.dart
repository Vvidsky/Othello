import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:othello/Components/my_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/fire_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String get routeName => 'login';
  static String get routeLocation => '/$routeName';

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _focusEmail.unfocus();
          _focusPassword.unfocus();
        },
        child: Scaffold(
            body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            buildAppName(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 24)),
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
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36)),
                    const Text(
                      'Login',
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
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text('Email',
                                      style: TextStyle(fontSize: 16)),
                                  TextFormField(
                                    controller: _emailTextController,
                                    focusNode: _focusEmail,
                                    // The validator receives the text that the user has entered.
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter email',
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 2.0)),
                                        isDense: true),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4)),
                                  const Text('Password',
                                      style: TextStyle(fontSize: 16)),
                                  TextFormField(
                                    controller: _passwordTextController,
                                    focusNode: _focusPassword,
                                    // The validator receives the text that the user has entered.
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter Password',
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
                                            minimumSize:
                                                MaterialStateProperty.all(
                                                    const Size(150, 40)),
                                            shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                          ),
                                          onPressed: () async {
                                            _focusEmail.unfocus();
                                            _focusPassword.unfocus();
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await login(_emailTextController,
                                                  _passwordTextController);
                                            }
                                          },
                                          child: _isProcessing
                                              ? const SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 3,
                                                          color: Colors.white),
                                                )
                                              : const Text('Login'),
                                        ),
                                      )),
                                ],
                              ))
                        ],
                      ))),
            )
          ]),
        )));
  }

  Future login(email, password) async {
    setState(() => _isProcessing = true);
    User? user = await FireAuth.signInUsingEmailPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
        context: context);
    Future.delayed(const Duration(seconds: 1)).then((value) {
      setState(() => _isProcessing = false);
      if (user != null) {
        if (context.mounted) context.go('/users/${user.uid}');
      }
    });
  }
}
