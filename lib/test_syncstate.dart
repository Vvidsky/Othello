import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:othello/models/room_data.dart';

import 'models/coordinate.dart';

const double BLOCK_SIZE = 40;
const int ITEM_EMPTY = 0;
const int ITEM_WHITE = 1;
const int ITEM_BLACK = 2;

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
  int currentTurn = ITEM_BLACK;
  bool isYourTurn = false;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  ValueNotifier<int> blackNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> whiteNotifier = ValueNotifier<int>(0);
  int countItemWhite = 0;
  int countItemBlack = 0;

  @override
  void initState() {
    dbRef
        .child('GameRooms/${widget.roomid}/board')
        .onChildChanged
        .listen((event) {
      loadState();
      print("listen $table");
      tableNotifier.value = table;
    });
    dbRef
        .child('GameRooms/${widget.roomid}/players')
        .onChildAdded
        .listen((event) {
      assignColortoPlayers();
      loadState();
    });
    initTable();
    loadState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: const Color(0xfffbf9f3),
          child: Column(children: <Widget>[
            buildMenu(),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xff34495e),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(width: 8, color: const Color(0xff2c3e50))),
                  child: ValueListenableBuilder(
                    valueListenable: tableNotifier,
                    builder: (context, value, widget) {
                      return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buildTable());
                    },
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: blackNotifier,
              builder: (context, value, widget) {
                return buildScoreTab();
              }
            )
          ])),
    );
  }

  Container buildMenu() {
    return Container(
      padding: const EdgeInsets.only(top: 36, bottom: 12, left: 16, right: 16),
      color: const Color(0xff34495e),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        GestureDetector(
            onTap: () {},
            child: Container(
                constraints: const BoxConstraints(minWidth: 120),
                decoration: BoxDecoration(
                    color: const Color(0xff27ae60),
                    borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.all(12),
                child: Column(children: <Widget>[
                  const Text("New Game",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ]))),
        Expanded(child: Container()),
        Container(
            constraints: const BoxConstraints(minWidth: 120),
            decoration: BoxDecoration(
                color: const Color(0xffbbada0),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("TURN",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: buildItem(currentTurn))
                ]))
      ]),
    );
  }

  Widget buildScoreTab() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(
          child: Container(
              color: const Color(0xff34495e),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(16),
                        child: buildItem(ITEM_WHITE)),
                    Text("x $countItemWhite",
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                  ]))),
      Expanded(
          child: Container(
              color: const Color(0xffbdc3c7),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(16),
                        child: buildItem(ITEM_BLACK)),
                    Text("x $countItemBlack",
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))
                  ])))
    ]);
  }

  void updateCountItem() {
    countItemBlack = 0;
    countItemWhite = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (table[row][col] == ITEM_BLACK) {
          countItemBlack++;
        } else if (table[row][col] == ITEM_WHITE) {
          countItemWhite++;
        }
      }
    }
  }

  void loadState() async {
    RoomData? roomData;
    List<List<int>>? newValue;
    final fuckingEvent = await dbRef
        .child("GameRooms/${widget.roomid}")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent fuck) {
      Map<dynamic, dynamic> values = fuck.snapshot.value as Map;
      // firebaseSuck = RoomData(
      //     id: fuck.snapshot.key,
      //     board: values["board"],
      //     currentTurn: values['currentTurn']);
      roomData = RoomData.fromJsonWithId(fuck.snapshot.key, values);
      // Map<dynamic, dynamic> values = fuck.snapshot.value as Map;
      // values.forEach((key, values) {
      //   firebaseSuck = RoomData(
      //       id: key,
      //       board: values["board"],
      //       currentTurn: values["currentTurn"]);
      //   // print("Error here ${values["board"].runtimeType}");
      //   // print(values["board"][0]);
      // });
      countItemBlack = values['blackCount'];
      countItemWhite = values['whiteCount'];
    });
    print('${roomData!.id} board ${roomData!.board!}');
    newValue = roomData!.board!.map((dynamic element) {
      List<int> subList = [];
      for (int value in element) {
        subList.add(value);
      }
      return subList;
    }).toList();
    // print('loadstate currentTurn: $currentTurn');
    currentTurn = roomData!.currentTurn!;
    table = newValue;
    tableNotifier.value = table;
    blackNotifier.value = countItemBlack;
    whiteNotifier.value = countItemWhite;
    // print("after loadState $table");
    // print("Error here outside ${firebaseSuck!.board![3]}");
    // print(firebaseSuck!.currentTurn);
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

  Widget buildBlockUnit(int row, int col) {
    return GestureDetector(
        onTap: () {
          setState(() {
            pasteItemToTable(row, col, currentTurn);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff27ae60),
            borderRadius: BorderRadius.circular(2),
          ),
          width: BLOCK_SIZE,
          height: BLOCK_SIZE,
          margin: const EdgeInsets.all(2),
          child: Center(child: buildItem(table[row][col])),
        ));
  }

  Widget buildItem(int block) {
    if (block == ITEM_BLACK) {
      return Container(
          width: 30,
          height: 30,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.black));
    } else if (block == ITEM_WHITE) {
      return Container(
          width: 30,
          height: 30,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white));
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

  Future<bool> pasteItemToTable(int row, int col, int item) async {
    await checkTurn();
    print('My fucking current turn $isYourTurn');
    if (isYourTurn) {
      if (table[row][col] == ITEM_EMPTY) {
        List<Coordinate> listCoordinate = [];
        listCoordinate.addAll(checkRight(row, col, item));
        listCoordinate.addAll(checkDown(row, col, item));
        listCoordinate.addAll(checkLeft(row, col, item));
        listCoordinate.addAll(checkUp(row, col, item));
        listCoordinate.addAll(checkUpLeft(row, col, item));
        listCoordinate.addAll(checkUpRight(row, col, item));
        listCoordinate.addAll(checkDownLeft(row, col, item));
        listCoordinate.addAll(checkDownRight(row, col, item));

        if (listCoordinate.isNotEmpty) {
          table[row][col] = item;
          inverseItemFromList(listCoordinate);
          currentTurn = inverseItem(currentTurn);
          // print('current turn is $currentTurn');
          updateCountItem();
          final gameState = {
            'board': table,
            'currentTurn': currentTurn,
            'winner': '',
            'whiteCount': countItemBlack,
            'blackCount': countItemWhite,
          };
          dbRef.child('GameRooms/${widget.roomid}').update(gameState);
          return true;
        }
      }
    }
    return false;
  }

  void assignColortoPlayers() async {
    int player1Color;
    int player2Color;
    List<List<int>>? newValue;
    final dbEvent = await dbRef
        .child("GameRooms/${widget.roomid}/players/player1")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent databaseEvent) {
      Map<dynamic, dynamic> value = databaseEvent.snapshot.value as Map;
      player1Color = value['color'];
    });
    var random = Random();
    player1Color = random.nextInt(2) + 1;
    player2Color = inverseItem(player1Color);
    dbRef.update(
        {'GameRooms/${widget.roomid}/players/player1/color': player1Color});
    dbRef.update(
        {'GameRooms/${widget.roomid}/players/player2/color': player2Color});
  }

  Future<bool> checkTurn() async {
    isYourTurn = false;
    final dbEvent = await dbRef
        .child("GameRooms/${widget.roomid}/players")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent databaseEvent) {
      Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
      values.forEach((key, values) {
        bool checkUser =
            values['uid'] == FirebaseAuth.instance.currentUser!.uid;
        print('checkuser: $checkUser');
        if (values['uid'] == FirebaseAuth.instance.currentUser!.uid) {
          bool checkColor = values['color'] == currentTurn;
          print('checkColor: $checkColor');
          if (values['color'] == currentTurn) {
            isYourTurn = true;
            print('final isYourTurn $isYourTurn');
            return;
          }
        }
      });
    });
    return isYourTurn;
  }

  void inverseItemFromList(List<Coordinate> list) {
    for (Coordinate c in list) {
      table[c.row][c.col] = inverseItem(table[c.row][c.col]);
    }
  }

  int inverseItem(int item) {
    if (item == ITEM_WHITE) {
      return ITEM_BLACK;
    } else if (item == ITEM_BLACK) {
      return ITEM_WHITE;
    }
    return item;
  }

  List<Coordinate> checkRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (col + 1 < 8) {
      for (int c = col + 1; c < 8; c++) {
        if (table[row][c] == item) {
          return list;
        } else if (table[row][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: row, col: c));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (col - 1 >= 0) {
      for (int c = col - 1; c >= 0; c--) {
        if (table[row][c] == item) {
          return list;
        } else if (table[row][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: row, col: c));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkDown(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8) {
      for (int r = row + 1; r < 8; r++) {
        if (table[r][col] == item) {
          return list;
        } else if (table[r][col] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: col));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkUp(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0) {
      for (int r = row - 1; r >= 0; r--) {
        if (table[r][col] == item) {
          return list;
        } else if (table[r][col] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: col));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkUpLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0 && col - 1 >= 0) {
      int r = row - 1;
      int c = col - 1;
      while (r >= 0 && c >= 0) {
        if (table[r][c] == item) {
          return list;
        } else if (table[r][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r--;
        c--;
      }
    }
    return [];
  }

  List<Coordinate> checkUpRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0 && col + 1 < 8) {
      int r = row - 1;
      int c = col + 1;
      while (r >= 0 && c < 8) {
        if (table[r][c] == item) {
          return list;
        } else if (table[r][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r--;
        c++;
      }
    }
    return [];
  }

  List<Coordinate> checkDownLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8 && col - 1 >= 0) {
      int r = row + 1;
      int c = col - 1;
      while (r < 8 && c >= 0) {
        if (table[r][c] == item) {
          return list;
        } else if (table[r][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r++;
        c--;
      }
    }
    return [];
  }

  List<Coordinate> checkDownRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8 && col + 1 < 8) {
      int r = row + 1;
      int c = col + 1;
      while (r < 8 && c < 8) {
        if (table[r][c] == item) {
          return list;
        } else if (table[r][c] == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r++;
        c++;
      }
    }
    return [];
  }
}
