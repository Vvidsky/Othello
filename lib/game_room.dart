import 'package:flutter/material.dart';

class GameRoom extends StatefulWidget {
  final String roomid;
  const GameRoom({super.key, required this.roomid});

  @override
  State<StatefulWidget> createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.roomid)
    );
  }

}

