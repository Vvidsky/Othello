import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: Colors.white)),
                  child: const Icon(
                    Icons.question_mark_rounded,
                    color: Colors.black,
                  ),
                ),
                const Text("How to play Othello"),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  context.go('/');
                },
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10))
            ]),
        body: Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
          children: <Widget>[
            RichText(
                text: const TextSpan(
                    text: 'Othello ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                    children: [
                      TextSpan(text:'is a strategy board game for two players (Black and White), played on an 8x8 board. The game begins with four discs placed in the middle of the board as shown below. Generally, Black will take the first move.', style: TextStyle(height: 1.5, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black))
                    ])),

          ],
        )));
  }
}
