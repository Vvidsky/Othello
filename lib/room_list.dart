import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final databaseReference = FirebaseDatabase.instance.ref();
  Query dbRef = FirebaseDatabase.instance.ref('GameRooms');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            if (!snapshot.exists) {
              return Text("No Data");
            }
            Map devTeam = snapshot.value as Map;
            devTeam['key'] = snapshot.key;
            return listItem(student: devTeam);
          }),
      floatingActionButton: FloatingActionButton(onPressed: createData, child: const Icon(Icons.add),),
    );
  }

  Widget listItem({required Map student}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      color: Colors.amberAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            student['players']['player1']['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            student['players']['player2']['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
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
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam2": {
    //     'name': 'Yashwant Kumar',
    //     'description': 'Senior Software Engineer'
    //   }
    // });
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam3": {'name': 'Akshay', 'description': 'Software Engineer'}
    // });
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam4": {'name': 'Aditya', 'description': 'Software Engineer'}
    // });
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam5": {
    //     'name': 'Shaiq',
    //     'description': 'Associate Software Engineer'
    //   }
    // });
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam6": {
    //     'name': 'Mohit',
    //     'description': 'Associate Software Engineer'
    //   }
    // });
    // databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam7": {
    //     'name': 'Naveen',
    //     'description': 'Associate Software Engineer'
    //   }
    // });
    //     databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam8": {
    //     'name': 'Kuasnali',
    //     'description': 'Associate Software Engineer'
    //   }
    // });
    //     databaseReference.child("GameRooms").update({
    //   "flutterDevsTeam9": {
    //     'name': 'Ayaka',
    //     'description': 'Associate Software Engineer'
    //   }
    // });
  }

  dynamic readData() {
    databaseReference.once().then((DatabaseEvent event) {
      return event.snapshot.value;
    });
  }
}
