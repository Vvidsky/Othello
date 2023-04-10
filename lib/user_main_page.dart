import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:othello/login.dart';
import 'my_component.dart';


// class UserMainPage extends StatelessWidget {
//   const UserMainPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if(snapshot.hasData) {
//             return _UserMainPage();
//           } else {
//             return const LoginPage();
//           }
//         },
//       )
//     );
//   }
// }

class UserMainPage extends StatelessWidget {
  const UserMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 72.0),
            ),
            buildAppName(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64.0),
            ),
            ElevatedButton(
                onPressed: () => context.go('/rooms/test_room'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  minimumSize: MaterialStateProperty.all(const Size(240, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                ),
                child: const Text(
                  'Create room',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () => context.go('/rooms'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'Join room',
                      style: TextStyle(fontSize: 20),
                    ))),
                  Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () => context.go('/howtoplay'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'How to Play?',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ))),
                    Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      context.go('/');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 20),
                    ))),
          ],
        ),
      ),
    );
  }
}