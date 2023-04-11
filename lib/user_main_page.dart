import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:othello/login.dart';
import 'my_component.dart';

class UserMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserMainPage();
  }
}

class _UserMainPage extends State<UserMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 72.0),
            ),
            buildAppName(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64.0),
            ),
            ElevatedButton(
                onPressed: () => context.push('/rooms/test_room'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  minimumSize: MaterialStateProperty.all(const Size(240, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                ),
                child: const Text(
                  'Create room',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () => context.push('/rooms'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'Join room',
                      style: TextStyle(fontSize: 20),
                    ))),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () => context.push('/howtoplay'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'How to Play?',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ))),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        context.go('/');
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 20),
                    ))),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: MaterialButton(
                  onPressed: () => {},
                  child: FutureBuilder<String>(
                      future: getUserName(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Text("Logged in as ${snapshot.data!}");
                        } else {
                          return const Text("Loading...");
                        }
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getUserName() async {
    var userCollection = FirebaseFirestore.instance.collection('/users');
    if (FirebaseAuth.instance.currentUser != null) {
      return userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) => value['name']);
    } else {
      return "";
    }
  }
}
