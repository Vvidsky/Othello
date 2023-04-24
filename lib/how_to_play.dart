import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: const <Widget>[
                // Container(
                //   margin: const EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(100),
                //       border: Border.all(width: 2, color: Colors.white)),
                //   child: const Icon(
                //     Icons.question_mark_rounded,
                //     color: Colors.black,
                //   ),
                // ),
                Text("How to play Othello"),
              ],
            ),
            // actions: <Widget>[
            //   IconButton(
            //     icon: const Icon(Icons.home),
            //     onPressed: () {
            //       context.go('/');
            //     },
            //   ),
            //   const Padding(padding: EdgeInsets.symmetric(horizontal: 10))
            // ]
            ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
          children: <Widget>[
            const SizedBox(height: 8),
            RichText(
                text: const TextSpan(
                    text: 'Othello ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'is a strategy board game for two players (Black and White), played on an 8x8 board. The game begins with four discs placed in the middle of the board as shown below. Generally, Black will take the first move.', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
              const SizedBox(height: 8),
              Image.asset('images/howtoplay01 - setup.png'),
              RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'If two players are in the game, the screen of the player with black disc will display the possible moves. The possible moves are the moves where a player can place a disc that form a row that ends with the player color horizontally, vertically, or diagonally', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
              Image.asset('images/howtoplay02 - possible_moves.png'),
              RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'After the first player made a move, the second player will see the possible moves while the first player needs to wait for the opponent to place a disc', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
              Image.asset('images/howtoplay03 - nextTurn.png'),
              RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'The players will keep placing discs until the board is full. After that, count the total number of discs. The player with more discs on the board is the winner. After the game finished, the user can choose to rematch(stay in the game room) or quit the game for a new match', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
              Image.asset('images/howtoplay04 - winning_screen.png'),
              RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'In addition, there are some cases where one of the players completely take over the board. In these cases the player with 0 disc is the loser', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
              Image.asset('images/howtoplay04 - special_win.png'),
              RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:"Finally, the game can also end when both players don't have any legal move.", style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),
          ],
        )));
  }
}
