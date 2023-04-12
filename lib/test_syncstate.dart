import 'dart:math';

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

const double BLOCK_SIZE = 40;
const int ITEM_EMPTY = 0;
const int ITEM_WHITE = -1;
const int ITEM_BLACK = 1;

class SyncState extends StatefulWidget {
  final String roomid;
  const SyncState({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _SyncState();
}

class _SyncState extends State<SyncState> {
  late int counter;
  List<List<int>> table = [];
  ValueNotifier<List<List<int>>> tableNotifier =
      ValueNotifier<List<List<int>>>([]);
  final playerPointsToAdd = ValueNotifier<int>(0);
  int currentTurn = 0;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    dbRef.child('GameRooms/${widget.roomid}').onChildChanged.listen((event) {
      loadState();
      print("listen $table");
      tableNotifier.value = table;
    });
    createNewRoom();
    print("after build $table");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color(0xfffbf9f3),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff34495e),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 6, color: Color(0xff2c3e50))),
              child: ValueListenableBuilder(
                //TODO 2nd: listen playerPointsToAdd
                valueListenable: tableNotifier,
                builder: (context, value, widget) {
                  //TODO here you can setState or whatever you need
                  return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildTable());
                },
              ),
            ),
          )),
    );
  }

  void loadState() async {
    RoomData? firebaseSuck;
    List<List<int>>? newValue;
    final fuckingEvent = await dbRef
        .child("GameRooms/${widget.roomid}")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent fuck) {
          Map<dynamic, dynamic> values = fuck.snapshot.value as Map;
            firebaseSuck = RoomData(
            id: fuck.snapshot.key,
            board: values["board"],
            currentTurn: values['currentTurn']);
      // Map<dynamic, dynamic> values = fuck.snapshot.value as Map;
      // values.forEach((key, values) {
      //   firebaseSuck = RoomData(
      //       id: key,
      //       board: values["board"],
      //       currentTurn: values["currentTurn"]);
      //   // print("Error here ${values["board"].runtimeType}");
      //   // print(values["board"][0]);
      // });
    });
    print('${firebaseSuck!.id} keboard ${firebaseSuck!.board!}');
    newValue = firebaseSuck!.board!.map((dynamic element) {
      List<int> subList = [];
      for (int value in element) {
        subList.add(value);
      }
      return subList;
    }).toList();
    print('int list $newValue');
    table = newValue;
    tableNotifier.value = table;
    print("after loadState $table");
    // print("Error here outside ${firebaseSuck!.board![3]}");
    // print(firebaseSuck!.currentTurn);
  }

  void createNewRoom() async {
    initTable();
    final data = await dbRef
        .child("GameRooms/${widget.roomid}")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent event) {
      if (!event.snapshot.exists) {
        initTableItems();
        final gameState = {
          'board': table,
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
      loadState();
    });
  }

  List<Row> buildTable() {
    List<Row> listRow = [];
    for (int row = 0; row < 8; row++) {
      List<Widget> listCol = [];
      for (int col = 0; col < 8; col++) {
        listCol.add(buildBlockUnit(row, col));
      }
      Row rowWidget = Row(mainAxisSize: MainAxisSize.min, children: listCol);
      listRow.add(rowWidget);
    }
    return listRow;
  }

  Container buildBlockUnit(int row, int col) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff27ae60),
        borderRadius: BorderRadius.circular(2),
      ),
      width: BLOCK_SIZE,
      height: BLOCK_SIZE,
      margin: EdgeInsets.all(2),
      child: Center(child: buildItem(table[row][col])),
    );
  }

  Widget buildItem(int block) {
    if (block == ITEM_BLACK) {
      return Container(
          width: 30,
          height: 30,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.black));
    } else if (block == ITEM_WHITE) {
      return Container(
          width: 30,
          height: 30,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white));
    }
    return Container();
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
    table[3][3] = ITEM_WHITE;
    table[4][3] = ITEM_BLACK;
    table[3][4] = ITEM_BLACK;
    table[4][4] = ITEM_WHITE;
  }
}
