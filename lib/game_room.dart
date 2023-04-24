import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:othello/models/player.dart';

import 'package:othello/models/room_data.dart';
import 'package:othello/utils/fire_db.dart';

import 'models/coordinate.dart';

const double blockSize = 40;
const int itemEmpty = 0;
const int itemWhite = 1;
const int itemBlack = 2;

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

class GameRoom extends StatefulWidget {
  final String roomid;
  const GameRoom({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _GameRoom();
}

class _GameRoom extends State<GameRoom> {
  List<List<int>> table = [];
  ValueNotifier<List<List<int>>> tableNotifier =
      ValueNotifier<List<List<int>>>([]);
  final playerPointsToAdd = ValueNotifier<int>(0);
  int currentTurn = 0;
  int numPossibleMoves = 0;
  bool isYourTurn = false;
  int yourColor = 0;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  User? currentUser = FirebaseAuth.instance.currentUser;
  int countItemWhite = 0;
  int countItemBlack = 0;
  int winner = -1;
  ValueNotifier<String> whitePlayerNotifier = ValueNotifier<String>("");
  ValueNotifier<String> blackPlayerNotifier = ValueNotifier<String>("");
  ValueNotifier<int> currentTurnNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> yourColorNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> blackNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> whiteNotifier = ValueNotifier<int>(0);

  late Player me;
  late Player opponent;
  late StreamSubscription<DatabaseEvent> boardListener;
  late StreamSubscription<DatabaseEvent> playerListener;
  late StreamSubscription<DatabaseEvent> turnChangeListener;
  late StreamSubscription<DatabaseEvent> quitListener;
  late StreamSubscription<DatabaseEvent> winnerListener;

  @override
  void initState() {
    initTable();
    try {
      boardListener = dbRef
          .child('GameRooms/${widget.roomid}/board')
          .onValue
          .listen((event) async {
        await loadState();
        // tableNotifier.value = table;
      });
      turnChangeListener = dbRef
          .child('GameRooms/${widget.roomid}/numPossibleMoves')
          .onValue
          .listen((event) async {
        // print('snapshot value ${event.snapshot.value}');
        try {
          if (event.snapshot.value as int == 0) {
            await loadState();
          }
        } catch (e) {
          print('possible move is null');
        }
      });
      playerListener = dbRef
          .child('GameRooms/${widget.roomid}/players')
          .onChildAdded
          .listen((event) async {
        await assignColortoPlayers();
        print('${event.snapshot.value}');
      });
      quitListener = dbRef
          .child('GameRooms/${widget.roomid}/players')
          .onChildRemoved
          .listen((event) async {
        await loadState();
      });
      winnerListener = dbRef
          .child('GameRooms/${widget.roomid}/winner')
          .onValue
          .listen((event) async {
        // print('winner triggered');
        // print('winner event ${event.snapshot.value}');
        // print('black $countItemBlack, white $countItemWhite');
        if (mounted) {
          if (event.snapshot.value == 1 || event.snapshot.value == 2) {
            print('your color $yourColor');
            winner = event.snapshot.value as int;
            try {
              await loadState();
            } catch (e) {
              print("can't loadstate");
            }
            try {
              await dbRef
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
              await dbRef.child("GameRooms/${widget.roomid}/players").remove();
            } catch (e) {
              print('no room');
            }
          }
        }
      });
    } catch (e) {
      Exception(e);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    turnChangeListener.cancel();
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
            const SizedBox(height: 40),
            GestureDetector(
                onTap: _resignDialogBuilder,
                child: Container(
                    constraints: const BoxConstraints(minWidth: 120),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const <Widget>[
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
            ValueListenableBuilder2<int, int>(
                first: blackNotifier,
                second: whiteNotifier,
                builder: (context, value, anothervalue, widget) {
                  return Container(
                      padding: const EdgeInsets.all(20),
                      child: buildScoreBoard());
                }),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 8, color: Colors.black)),
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
            const SizedBox(height: 100)
          ])),
    );
  }

  Container buildScoreBoard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.grey.shade300),
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 16, right: 16),
      child: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
                child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.all(16),
                          child: buildItem(itemWhite)),
                      Text("x $countItemWhite",
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black))
                    ]),
                ValueListenableBuilder(
                    valueListenable: whitePlayerNotifier,
                    builder: (context, value, widget) {
                      if (value.isEmpty) {
                        return const Text("None");
                      }
                      return Text(value);
                    })
              ],
            )),
            Expanded(
                child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(16),
                                  child: buildItem(itemBlack)),
                              Text("x $countItemBlack",
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ],
                      )
                    ]),
                ValueListenableBuilder(
                    valueListenable: blackPlayerNotifier,
                    builder: (context, value, widget) {
                      if (value.isEmpty) {
                        return const Text("None");
                      }
                      return Text(value);
                    })
              ],
            ))
          ]),
          Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            StreamBuilder(
                stream: dbRef
                    .child('GameRooms/${widget.roomid}/currentTurn')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    currentTurn = snapshot.data!.snapshot.value != null
                        ? snapshot.data!.snapshot.value as int
                        : 0;
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValueListenableBuilder(
                                valueListenable: yourColorNotifier,
                                builder: (context, value, child) {
                                  if (currentTurn == -1) {
                                    if (winner == 1 || winner == 2) {
                                      return buildGameMessage("Game finished");
                                    }
                                    return buildGameMessage(
                                        "Waiting for a player to join the game");
                                  }
                                  if (currentTurn == yourColor) {
                                    return buildGameMessage(
                                        "Your's turn (${convertColorCode(yourColor)})");
                                  } else {
                                    return buildGameMessage("Opponent's turn");
                                  }
                                })
                          ],
                        ),
                      ),
                    );
                  }
                  return const Text("null");
                }),
          ]),
        ],
      ),
    );
  }

  Container buildGameMessage(String message) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.lightBlue.shade300,
            border: Border.all(
              color: Colors.lightBlue,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Text(message));
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
                        child: buildItem(itemWhite)),
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
                        child: buildItem(itemBlack)),
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
        if (table[row][col] == itemBlack) {
          countItemBlack++;
        } else if (table[row][col] == itemWhite) {
          countItemWhite++;
        }
      }
    }
  }

  void resign() async {
    Player? player1;
    Player? player2;
    await dbRef
        .child('GameRooms/${widget.roomid}/winner')
        .set(inverseItem(yourColor));
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

  Future loadState() async {
    RoomData? roomData;
    List<List<int>>? newValue;
    try {
      await Future.delayed(const Duration(milliseconds: 200));
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
          if (values['players']['player1']['color'] == itemWhite) {
            whitePlayerNotifier.value =
                values['players']['player1']['username'];
            blackPlayerNotifier.value =
                values['players']['player2']['username'];
          }
          if (values['players']['player1']['color'] == itemBlack) {
            blackPlayerNotifier.value =
                values['players']['player1']['username'];
            whitePlayerNotifier.value =
                values['players']['player2']['username'];
          }
        }
        // print('loadState yourColor: $yourColor');
      });
      // print(yourColor);
      // print('${roomData!.id} board ${roomData!.board!}');
      newValue = roomData!.board!.map((dynamic element) {
        List<int> subList = [];
        for (int value in element) {
          subList.add(value);
        }
        return subList;
      }).toList();
      // print('loadstate currentTurn: $currentTurn');
      int previousPossibleMoves = roomData!.numPossibleMoves!;
      currentTurn = roomData!.currentTurn!;
      table = newValue;
      await Future.delayed(const Duration(milliseconds: 400));
      if (isYourTurn = await checkTurn()) {
        numPossibleMoves = showPossibleMoves(currentTurn);
        if (numPossibleMoves == 0) {
          if (previousPossibleMoves == 0) {
            int winner = checkWinner();
            await dbRef.child('GameRooms/${widget.roomid}/winner').set(winner);
            await dbRef.child('GameRooms/${widget.roomid}/currentTurn').set(-1);
          }
          await dbRef.child("GameRooms/${widget.roomid}").update({
            "currentTurn": inverseItem(currentTurn),
            "numPossibleMoves": numPossibleMoves
          });
        }
        // print("numPossible moves: $numPossibleMoves");
      }
      tableNotifier.value = table;
      blackNotifier.value = countItemBlack;
      whiteNotifier.value = countItemWhite;

      // print("after loadState $table");
    } catch (e) {
      print('loadState error $e');
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
          width: blockSize,
          height: blockSize,
          margin: const EdgeInsets.all(2),
          child: Center(child: buildItem(table[row][col])),
        ));
  }

  Widget buildItem(int block) {
    if (block == itemBlack) {
      return Container(
          width: 30,
          height: 30,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.black));
    } else if (block == itemWhite) {
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
              color: currentTurn == itemBlack
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

  int showPossibleMoves(int item) {
    var count = 0;
    List<Coordinate> listPossibleMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        List<Coordinate> listCoordinate = [];
        if (table[row][col] == itemEmpty) {
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
        count += 1;
      }
      // print("there are possible moves");
    }
    return count;
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
            'numPossibleMoves': numPossibleMoves,
            'discsCount': {
              'whiteCount': countItemWhite,
              'blackCount': countItemBlack,
            },
          };
          await dbRef.child('GameRooms/${widget.roomid}').update(gameState);
          if (countItemBlack + countItemWhite == 64 ||
              countItemBlack == 0 ||
              countItemWhite == 0) {
            int winner = checkWinner();
            await dbRef.child('GameRooms/${widget.roomid}/winner').set(winner);
            await dbRef.child('GameRooms/${widget.roomid}/currentTurn').set(-1);
          }
          return true;
        }
      }
    }
    return false;
  }

  Future assignColortoPlayers() async {
    try {
      await dbRef
          .child("GameRooms/${widget.roomid}/players")
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) async {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        // print(value['player2'] == null);
        if (values.length == 2 &&
            (values['player2']['color'] == 0 ||
                values['player1']['color'] == 0)) {
          if (currentUser!.uid == values['player1']['uid']) {
            me = Player.fromJson(values['player1']);
            opponent = Player.fromJson(values['player2']);
          } else {
            me = Player.fromJson(values['player2']);
            opponent = Player.fromJson(values['player1']);
          }
          var random = Random();
          me.color = random.nextInt(2) + 1;
          opponent.color = inverseItem(me.color!);
          yourColor = me.color!;
          yourColorNotifier.value = me.color!;
          await dbRef.update(
              {'GameRooms/${widget.roomid}/players/player1/color': me.color});
          await dbRef.update({
            'GameRooms/${widget.roomid}/players/player2/color': opponent.color
          });
          await dbRef.update({'GameRooms/${widget.roomid}/currentTurn': 2});
        }
      });
      print('New player yourColor: $yourColor');
      if (yourColor != 0) {
        await loadState();
      }
    } catch (e) {
      print("can't assign colors to players");
    }
  }

  Future<bool> checkTurn() async {
    isYourTurn = false;
    try {
      await dbRef
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
    } catch (e) {
      print("Check turn on null gameroom");
    }

    return isYourTurn;
  }

  void inverseItemFromList(List<Coordinate> list) {
    for (Coordinate c in list) {
      table[c.row][c.col] = inverseItem(table[c.row][c.col]);
    }
  }

  int inverseItem(int item) {
    if (item == itemWhite) {
      return itemBlack;
    } else if (item == itemBlack) {
      return itemWhite;
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
        } else if (table[row][c] == itemEmpty || table[row][c] == -1) {
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
        } else if (table[row][c] == itemEmpty || table[row][c] == -1) {
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
        } else if (table[r][col] == itemEmpty || table[r][col] == -1) {
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
        } else if (table[r][col] == itemEmpty || table[r][col] == -1) {
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
        } else if (table[r][c] == itemEmpty || table[r][c] == -1) {
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
        } else if (table[r][c] == itemEmpty || table[r][c] == -1) {
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
        } else if (table[r][c] == itemEmpty || table[r][c] == -1) {
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
        } else if (table[r][c] == itemEmpty || table[r][c] == -1) {
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
              onPressed: () async {
                await rematch();
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
        print(values.length);
        if (values.length == 1 &&
            values['player1']['uid'] == currentUser!.uid) {
          dbRef.child("GameRooms/${widget.roomid}").remove();
        } else {
          values.forEach((key, values) async {
            if (uid == values['uid']) {
              await dbRef
                  .child("GameRooms/${widget.roomid}/players/$key")
                  .remove();
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
    } catch (e) {
      dbRef.child("GameRooms/${widget.roomid}").remove();
      print("removing player error");
    }
    if (mounted) context.go('/');
  }

  String convertColorCode(int code) {
    if (code == itemBlack) {
      return "Black";
    }
    if (code == itemWhite) {
      return "White";
    }
    return "None";
  }

  Future<void> _resignDialogBuilder() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resign'),
          content: const Text("Are you sure to resign?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Confirm'),
                onPressed: () => resign()),
          ],
        );
      },
    );
  }

  Future rematch() async {
    await dbRef
        .child("GameRooms/${widget.roomid}")
        .once(DatabaseEventType.value)
        .then((DatabaseEvent databaseEvent) async {
      try {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        if (values['players'] != null) {
          if (values['players']['player1'] != null &&
              values['players']['player2'] != null) {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This room is full')));
            context.go('/');
            return;
          }
        }
        await dbRef
            .child("GameRooms/${widget.roomid}")
            .update({"winner": '', "currentTurn": -1, "numPossibleMoves": -1});
        await dbRef
            .child("GameRooms/${widget.roomid}/discsCount")
            .update({"blackCount": 2, "whiteCount": 2});

        String? username = await FireDb.getUserName();
        String? userid = currentUser!.uid;
        Player newPlayer = Player(uid: userid, username: username, color: 0);
        if (values['players'] == null) {
          await dbRef
              .child("GameRooms/${widget.roomid}/players")
              .update({"player1": newPlayer.toJson()});
        } else {
          if (values['players']['player1'] != null &&
              values['players']['player2'] == null) {
            await dbRef
                .child("GameRooms/${widget.roomid}/players")
                .update({"player2": newPlayer.toJson()});
          }
        }
        initTable();
        initTableItems();
        await dbRef
            .child("GameRooms/${widget.roomid}")
            .update({"board": table});
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        print("Cannot rematch $e");
      }
    });
  }

  void initTableItems() {
    table[3][3] = itemWhite;
    table[4][3] = itemBlack;
    table[3][4] = itemBlack;
    table[4][4] = itemWhite;
  }
}
