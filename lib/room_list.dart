import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';

import 'models/player.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final databaseReference = FirebaseDatabase.instance.ref();
  Query queryRef = FirebaseDatabase.instance.ref('GameRooms');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FirebaseAnimatedList(
          query: queryRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            if (!snapshot.exists) {
              return Text("No Data");
            }
            Map devTeam = snapshot.value as Map;
            devTeam['key'] = snapshot.key;
            return listItem(student: devTeam, context: context);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: createData,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem({required Map student, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      color: Colors.amberAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              student['key'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            trailing: ElevatedButton(
                onPressed: () => joinRoom(student['key']),
                child: const Text('Join')),
          )
        ],
      ),
    );
  }

  void createData() {
    final gameState = {
      'board': [
        [-1, -1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, 0, 1, -1, -1, -1],
        [-1, -1, -1, 1, 0, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1],
      ],
      'players': {
        'player1': {'name': 'Alice', 'score': 0},
        'player2': {'name': 'Bob', 'score': 0},
      },
      'currentTurn': 'player1',
    };
    databaseReference.child('GameRooms').child('Room1').set(gameState);
  }

  dynamic readData() {
    databaseReference.once().then((DatabaseEvent event) {
      return event.snapshot.value;
    });
  }

  void joinRoom(String? roomid) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final data = await dbRef
        .once(DatabaseEventType.value)
        .then((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        String? username = await getUserName();
        String? userid = FirebaseAuth.instance.currentUser!.uid;
        Player newPlayer = Player(uid: userid, username: username, color: 0);
        dbRef.update({'GameRooms/$roomid/players/player2': newPlayer.toJson()});
        context.push('/testroom/$roomid');
      } else {
        print("The data is already exsits");
      }
    });
  }

  void loadState() async {

  }

  Future<String> getUserName() async {
    var userCollection =
        firestore.FirebaseFirestore.instance.collection('/users');
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
