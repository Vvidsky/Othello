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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Room List"),
      ),
      body: FirebaseAnimatedList(
          query: queryRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            if (!snapshot.exists) {
              return const Text("No Data");
            }
            Map room = snapshot.value as Map;
            room['key'] = snapshot.key;
            return listItem(room: room, context: context);
          }),
    );
  }

  Widget listItem({required Map room, required BuildContext context}) {
    try {
      return room['winner'].toString().isEmpty? Container(
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
                room['key'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text('players ${room['players'].length} / 2'),
              trailing: ElevatedButton(
                  onPressed: room['players'].length == 2
                      ? null
                      : () => joinRoom(room['key']),
                  child: const Text('Join')),
            )
          ],
        ),
      ) : const SizedBox();
    } catch (e) {
      return const SizedBox.shrink();
    }
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
    await dbRef
        .once(DatabaseEventType.value)
        .then((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        String? username = await getUserName();
        String? userid = FirebaseAuth.instance.currentUser!.uid;
        Player newPlayer = Player(uid: userid, username: username, color: 0);
        var playerData =
            await dbRef.child('GameRooms/$roomid/players/player2').get();
        if (!playerData.exists) {
          await dbRef.update(
              {'GameRooms/$roomid/players/player2': newPlayer.toJson()});
        }
        if (context.mounted) {
          context.go('/rooms/$roomid');
        }
      } else {
        print("The data is already exsits");
      }
    });
  }

  void loadState() async {}

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
