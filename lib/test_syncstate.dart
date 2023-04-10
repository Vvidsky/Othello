import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoomData {
  String? id;
  List<dynamic>? board;
  String? currentTurn;

  RoomData({required this.id, required this.board, required this.currentTurn});

  RoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    board = json['board'];
    currentTurn = json['currentTurn'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'board': this.board,
      'currentTurn': this.currentTurn,
    };
  }
}

class SyncState extends StatefulWidget {
  final String roomid;
  const SyncState({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _SyncState();
}

class _SyncState extends State<SyncState> {
  late int counter;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    dbRef.child('GameRooms/${widget.roomid}').onChildChanged.listen((event) => print("state has changed"));
    createNewRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Test Update State")),
        body: buildList());
  }

  Widget buildList() {
    loadState();
    return ListView();
  }

  void loadState() async {
    RoomData? firebaseSuck;
    final fuckingEvent = await dbRef
        .child("GameRooms")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent fuck) {
      Map<dynamic, dynamic> values = fuck.snapshot.value as Map;
      values.forEach((key, values) {
        firebaseSuck = RoomData(
            id: key,
            board: values["board"],
            currentTurn: values["currentTurn"]);
        print("Error here ${values["board"].runtimeType}");
        print(values["board"][0]);
      });
    });
    print("Error here outside ${firebaseSuck!.board![3]}");
    print(firebaseSuck!.currentTurn);
  }

  void createNewRoom() async {
    final data = await dbRef
        .child("GameRooms")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent event) {
      if (event.snapshot.exists) {
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
        dbRef.child('GameRooms/${widget.roomid}').set(gameState);
      } else {
        print("The data is already exsits");
      }
    });
  }
}
