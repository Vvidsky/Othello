import 'package:flutter/material.dart';

class GameRoom extends StatefulWidget {
  final String roomid;
  const GameRoom({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _GameRoomState();
}

const double BLOCK_SIZE = 40;

class _GameRoomState extends State<GameRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: const Color(0xfffbf9f3),
          child: Center(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xff34495e),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 6, color: const Color(0xff2c3e50))),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildTable())),
          )),
    );
  }

  List<Row> buildTable() {
    List<Row> listRow = [];
    for (int row = 0; row < 8; row++) {
      List<Widget> listCol = [];
      for (int col = 0; col < 8; col++) {
        listCol.add(buildBlockUnit());
      }
      Row rowWidget = Row(mainAxisSize: MainAxisSize.min, children: listCol);
      listRow.add(rowWidget);
    }
    return listRow;
  }

  Container buildBlockUnit() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff27ae60),
        borderRadius: BorderRadius.circular(2),
      ),
      width: BLOCK_SIZE,
      height: BLOCK_SIZE,
      margin: const EdgeInsets.all(2),
      child: Center(child: buildItem()),
    );
  }

    Widget buildItem(){
    return Container(width: 30, height: 30,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white));
  }
}
