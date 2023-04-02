import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'my_component.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24)),
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
                                // The validator receives the text that the user has entered.
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter email',
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
                              const Text('Password',
                                  style: TextStyle(fontSize: 16)),
                              TextFormField(
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
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(150, 40)),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                      ),
                                      onPressed: () {
                                        // Validate returns true if the form is valid, or false otherwise.
                                        if (_formKey.currentState!.validate()) {
                                          // If the form is valid, display a snackbar. In the real world,
                                          // you'd often call a server or save the information in a database.
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Processing Data')),
                                          );
                                        }
                                      },
                                      child: const Text('Login'),
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
