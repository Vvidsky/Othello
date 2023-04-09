import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Player {
  String name;
  String symbol;

  Player(this.name, this.symbol);
}

class TicTacToeBoard extends StatefulWidget {
  final DatabaseReference gameRef;
  final Player player;
  TicTacToeBoard({required this.gameRef, required this.player});

  @override
  _TicTacToeBoardState createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard> {
  late List<String> _boardState = List.filled(9, '');
  late int _currentPlayerIndex = 0;
  List<Player> _players = [Player('Alice', 'X'), Player('Bob', 'O')];
  List<String> _playerSymbols = ['X', 'O'];

  @override
  void initState() {
    super.initState();
    widget.gameRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> gameState = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
        setState(() {
          _boardState = List<String>.from(gameState['boardState']);
          _currentPlayerIndex = gameState['currentPlayerIndex'];
          _players = List<Map>.from(gameState['players'])
              .map(
                  (playerMap) => Player(playerMap['name'], playerMap['symbol']))
              .toList();
        });
      }
    });
  }

  void _onSquareTapped(int index) {
    if (_boardState[index] == '' &&
        _currentPlayerIndex == _players.indexOf(widget.player)) {
      _boardState[index] = widget.player.symbol;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % 2;
      widget.gameRef.set({
        'boardState': _boardState,
        'currentPlayerIndex': _currentPlayerIndex,
        'players': _players
            .map((player) => {'name': player.name, 'symbol': player.symbol})
            .toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_boardState == null) {
      // Display a loading indicator until the game state is loaded from Firebase.
      return Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onSquareTapped(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(_boardState[index]),
            ),
          ),
        );
      },
    );
  }
}
