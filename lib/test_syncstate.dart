import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:othello/models/player.dart';

import 'package:othello/models/room_data.dart';
import 'package:othello/user_main_page.dart';

import 'models/coordinate.dart';

const double BLOCK_SIZE = 40;
const int ITEM_EMPTY = 0;
const int ITEM_WHITE = 1;
const int ITEM_BLACK = 2;

//ref: https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    required this.first,
    required this.second,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (context, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}

class SyncState extends StatefulWidget {
  final String roomid;
  const SyncState({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _SyncState();
}

class _SyncState extends State<SyncState> {
  List<List<int>> table = [];
  ValueNotifier<List<List<int>>> tableNotifier =
      ValueNotifier<List<List<int>>>([]);
  final playerPointsToAdd = ValueNotifier<int>(0);
  int currentTurn = ITEM_BLACK;
  bool isYourTurn = false;
  int yourColor = 0;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  User? currentUser = FirebaseAuth.instance.currentUser;
  int countItemWhite = 0;
  int countItemBlack = 0;
  ValueNotifier<int> blackNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> whiteNotifier = ValueNotifier<int>(0);

  late Player me;
  late Player opponent;
  late StreamSubscription<DatabaseEvent> boardListener;
  late StreamSubscription<DatabaseEvent> playerListener;
  late StreamSubscription<DatabaseEvent> quitListener;
  late StreamSubscription<DatabaseEvent> winnerListener;

  @override
  void initState() {
    initTable();
    try {
      boardListener = dbRef
          .child('GameRooms/${widget.roomid}/board')
          .onValue
          .listen((event) {
        loadState();
        // tableNotifier.value = table;
      });
      playerListener = dbRef
          .child('GameRooms/${widget.roomid}/players')
          .onChildAdded
          .listen((event) {
        assignColortoPlayers();
        loadState();
      });
      quitListener = dbRef
          .child('GameRooms/${widget.roomid}/players')
          .onChildRemoved
          .listen((event) {
        loadState();
      });
      winnerListener = dbRef
          .child('GameRooms/${widget.roomid}/winner')
          .onValue
          .listen((event) {
        print('winner triggered');
        print('winner event ${event.snapshot.value}');
        print('black $countItemBlack, white $countItemWhite');
        if (mounted) {
          if (event.snapshot.value == 1 || event.snapshot.value == 2) {
            print('your color $yourColor');
            try {
              dbRef
                  .child("GameRooms/${widget.roomid}")
                  .once(DatabaseEventType.value)
                  .then((DatabaseEvent databaseEvent) {
                try {
                  Map<dynamic, dynamic> values =
                      databaseEvent.snapshot.value as Map;
                  checkWinner();
                  _dialogBuilder(context, values['winner']);
                } catch (e) {
                  print("null error");
                }
                // print(player1!.uid);
              });
            } catch (e) {
              print('no room');
            }
          }
        }
      });
      loadState();
    } catch (e) {
      Exception(e);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    boardListener.cancel();
    playerListener.cancel();
    quitListener.cancel();
    winnerListener.cancel();
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
            ValueListenableBuilder2<int, int>(
                first: blackNotifier,
                second: whiteNotifier,
                builder: (context, value, anothervalue, widget) {
                  return buildScoreTab();
                }),
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
            onTap: resign,
            child: Container(
                constraints: const BoxConstraints(minWidth: 120),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.all(12),
                child: Row(children: const <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.red,
                  ),
                  Text("  Resign",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))
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

  void resign() async {
    Player? player1;
    Player? player2;
    try {
      await dbRef
          .child("GameRooms/${widget.roomid}/players/player1")
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        player1 = Player.fromJson(values);
        // print(player1!.uid);
      });
    } catch (e) {
      Exception(e);
    }
    try {
      await dbRef
          .child("GameRooms/${widget.roomid}/players/player2")
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        player2 = Player.fromJson(values);
      });
    } catch (e) {
      Exception(e);
    }
    if (player1 != null && player2 != null) {
      if (player1!.uid == FirebaseAuth.instance.currentUser!.uid &&
          player2!.uid!.isNotEmpty) {
        await dbRef
            .child('GameRooms/${widget.roomid}/players/player1')
            .set(player2?.toJson());
        await dbRef
            .child('GameRooms/${widget.roomid}/players/player2')
            .remove();
      }
      if (player2!.uid == FirebaseAuth.instance.currentUser!.uid &&
          player1!.uid!.isNotEmpty) {
        await dbRef
            .child('GameRooms/${widget.roomid}/players/player2')
            .remove();
      }
    }
    if (player2 == null) {
      // await dbRef.child('GameRooms/${widget.roomid}').remove();
      DataSnapshot dataSnapshot = await dbRef.child('GameRooms').get();
      Map<dynamic, dynamic> data = dataSnapshot.value as Map;
      await dbRef.child('GameRooms/${widget.roomid}').remove();
      // if (data.length >= 3) {
      //   await dbRef.child('GameRooms/${widget.roomid}').remove();
      // } else {
      //   await dbRef
      //       .child('GameRooms/${widget.roomid}/players/player1')
      //       .remove();
      // }
    }
    if (context.mounted) context.go('/');
  }

  void loadState() async {
    RoomData? roomData;
    List<List<int>>? newValue;
    try {
      await dbRef
          .child("GameRooms/${widget.roomid}")
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        roomData = RoomData.fromJsonWithId(databaseEvent.snapshot.key, values);
        countItemBlack = values['discsCount']['blackCount'];
        countItemWhite = values['discsCount']['whiteCount'];
        Map<dynamic, dynamic> players = values['players'] as Map;
        if (players.length == 2) {
          if (values['players']['player1']['uid'] ==
              FirebaseAuth.instance.currentUser!.uid) {
            yourColor = values['players']['player1']['color'];
          }
          if (values['players']['player2']['uid'] ==
              FirebaseAuth.instance.currentUser!.uid) {
            yourColor = values['players']['player2']['color'];
          }
        }
      });
      print(yourColor);
      // print('${roomData!.id} board ${roomData!.board!}');
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
      await Future.delayed(const Duration(milliseconds: 500));
      if (await checkTurn()) {
        showPossibleMoves(currentTurn);
      }
      tableNotifier.value = table;

      blackNotifier.value = countItemBlack;
      whiteNotifier.value = countItemWhite;

      // print("after loadState $table");
    } catch (e) {
      Exception(e);
    }
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
    } else if (block == -1) {
      return Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentTurn == ITEM_BLACK
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5)));
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

  List<Coordinate> showPossibleMoves(int item) {
    List<Coordinate> listPossibleMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        List<Coordinate> listCoordinate = [];
        if (table[row][col] == ITEM_EMPTY) {
          listCoordinate.addAll(checkRight(row, col, item));
          listCoordinate.addAll(checkDown(row, col, item));
          listCoordinate.addAll(checkLeft(row, col, item));
          listCoordinate.addAll(checkUp(row, col, item));
          listCoordinate.addAll(checkUpLeft(row, col, item));
          listCoordinate.addAll(checkUpRight(row, col, item));
          listCoordinate.addAll(checkDownLeft(row, col, item));
          listCoordinate.addAll(checkDownRight(row, col, item));
        }
        if (listCoordinate.isNotEmpty) {
          listPossibleMoves.add(Coordinate(row: row, col: col));
          // print(listPossibleMoves);
        }
      }
    }
    if (listPossibleMoves.isNotEmpty) {
      for (var element in listPossibleMoves) {
        // print('${element.row}, ${element.col}');
        table[element.row][element.col] = -1;
      }
    }
    return [];
  }

  void clearPossibleMoves() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (table[row][col] == -1) {
          table[row][col] = 0;
        }
      }
    }
  }

  Future<bool> pasteItemToTable(int row, int col, int item) async {
    await checkTurn();
    // print('My fucking current turn $isYourTurn');
    if (isYourTurn) {
      if (table[row][col] == -1) {
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
          clearPossibleMoves();
          final gameState = {
            'board': table,
            'currentTurn': currentTurn,
            'discsCount': {
              'whiteCount': countItemWhite,
              'blackCount': countItemBlack,
            },
          };
          dbRef.child('GameRooms/${widget.roomid}').update(gameState);
          if (countItemBlack + countItemWhite == 64 ||
              countItemBlack == 0 ||
              countItemWhite == 0) {
            int winner = checkWinner();
            dbRef.child('GameRooms/${widget.roomid}/winner').set(winner);
          }
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
        .child("GameRooms/${widget.roomid}/players")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent databaseEvent) {
      Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
      // print(value['player2'] == null);
      if (values.length == 2 &&
          (values['player2']['color'] == 0 || values['player1']['color'] == 0)) {
        if(currentUser!.uid == values['player1']['uid']) {
          me = Player.fromJson(values['player1']);
          opponent = Player.fromJson(values['player2']);
        } else {
          me = Player.fromJson(values['player2']);
          opponent = Player.fromJson(values['player1']);
        }
        var random = Random();
        player1Color = random.nextInt(2) + 1;
        player2Color = inverseItem(player1Color);
        dbRef.update(
            {'GameRooms/${widget.roomid}/players/player1/color': player1Color});
        dbRef.update(
            {'GameRooms/${widget.roomid}/players/player2/color': player2Color});
      }
    });
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
        // print('checkuser: $checkUser');
        if (values['uid'] == FirebaseAuth.instance.currentUser!.uid) {
          bool checkColor = values['color'] == currentTurn;
          // print('checkColor: $checkColor');
          if (values['color'] == currentTurn) {
            isYourTurn = true;
            // print('final isYourTurn $isYourTurn');
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

  int checkWinner() {
    print('black $countItemBlack, white $countItemWhite');
    if (countItemBlack == countItemWhite) return -1;
    if (countItemBlack > countItemWhite) return itemBlack;
    if (countItemWhite > countItemBlack) return itemWhite;
    return itemEmpty;
  }

  List<Coordinate> checkRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (col + 1 < 8) {
      for (int c = col + 1; c < 8; c++) {
        if (table[row][c] == item) {
          return list;
        } else if (table[row][c] == ITEM_EMPTY || table[row][c] == -1) {
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
        } else if (table[row][c] == ITEM_EMPTY || table[row][c] == -1) {
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
        } else if (table[r][col] == ITEM_EMPTY || table[r][col] == -1) {
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
        } else if (table[r][col] == ITEM_EMPTY || table[r][col] == -1) {
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
        } else if (table[r][c] == ITEM_EMPTY || table[r][c] == -1) {
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
        } else if (table[r][c] == ITEM_EMPTY || table[r][c] == -1) {
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
        } else if (table[r][c] == ITEM_EMPTY || table[r][c] == -1) {
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
        } else if (table[r][c] == ITEM_EMPTY || table[r][c] == -1) {
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

  Future<void> _dialogBuilder(BuildContext context, int gameWinner) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: Text(yourColor == gameWinner ? "You Win" : "You Lose"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Rematch'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Quit'),
              onPressed: () {
                removePlayerFromGame(currentUser!.uid);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removePlayerFromGame(String uid) async {
    Player? player2;
    try {
      await dbRef
          .child("GameRooms/${widget.roomid}/players")
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) async {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        if (values.length == 1) {
          dbRef.child("GameRooms/${widget.roomid}").remove();
        } else {
          values.forEach((key, values) async {
            if (uid == values['uid']) {
              await dbRef.child("GameRooms/${widget.roomid}/players/$key").remove();
              player2 = Player.fromJson(values);
            }
          });
          if (values['player1'] == null && values['player2'] != null) {
            await dbRef
                .child("GameRooms/${widget.roomid}/players/player1")
                .update(player2!.toJson());
          }
        }
      });
      if (mounted) context.go('/');
    } catch (e) {
      print("removing player error");
    }
  }
}
