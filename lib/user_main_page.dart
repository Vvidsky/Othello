import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'models/player.dart';
import 'Components/my_component.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserMainPage();
  }
}

const int itemEmpty = 0;
const int itemWhite = 1;
const int itemBlack = 2;

class _UserMainPage extends State<UserMainPage> {
  List<List<int>> table = [];
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

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
                onPressed: () async => createNewRoom(context),
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
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: FutureBuilder<String>(
                    future: getUserName(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Logged in as ${snapshot.data!}"),
                            TextButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance
                                      .signOut()
                                      .then((value) {
                                    FirebaseAuth.instance.authStateChanges();
                                    context.go('/');
                                  });
                                },
                                child: const Text('Logout'))
                          ],
                        );
                      } else {
                        return const Text("Loading...");
                      }
                    }),
              ),
            ),
            const SizedBox(height: 8)
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

  void createNewRoom(BuildContext context) async {
    var uuid = const Uuid().v1();

    initTable();
    initTableItems();
    await dbRef
        .child("GameRooms/$uuid")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent event) async {
      if (!event.snapshot.exists) {
        String? username = await getUserName();
        String? userid = FirebaseAuth.instance.currentUser!.uid;
        Player newPlayer = Player(uid: userid, username: username, color: 0);
        final gameState = {
          'board': table,
          'players': {
            'player1': newPlayer.toJson(),
            'player2': {},
          },
          'currentTurn': -1,
          'discsCount': {
            'whiteCount': 2,
            'blackCount': 2,
          },
          'winner': ''
        };
        dbRef.child('GameRooms/$uuid').set(gameState);
        if (context.mounted) context.go('/rooms/$uuid');
      } else {
        print("The data is already exsits");
      }
    });
  }

  void initTable() {
    table = [];
    for (int row = 0; row < 8; row++) {
      List<int> list = [];
      for (int col = 0; col < 8; col++) {
        list.add(0);
      }
      table.add(list);
    }
  }

  void initTableItems() {
    table[3][3] = itemWhite;
    table[4][3] = itemBlack;
    table[3][4] = itemBlack;
    table[4][4] = itemWhite;
  }
}
