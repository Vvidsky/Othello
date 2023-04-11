// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:othello/game_room.dart';
import 'package:othello/room_list.dart';
import 'package:othello/test_multiplayer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:othello/test_syncstate.dart';
import 'firebase_options.dart';
import 'my_component.dart';

import 'login.dart';
import 'game.dart';
import 'register.dart';
import 'user_main_page.dart';
import 'how_to_play.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    if (kDebugMode) {
      print('User is currently signed out!');
    }
  } else {
    if (kDebugMode) {
      print('User is signed in!');
    }
  }

  runApp(const MyApp());
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      redirect: (BuildContext context, GoRouterState state) {
        if (FirebaseAuth.instance.currentUser == null &&
            state.location == '/') {
          return null;
        } else {
          return '/users/${FirebaseAuth.instance.currentUser?.uid}';
        }
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
    GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
        redirect: (BuildContext context, GoRouterState state) {
          if (FirebaseAuth.instance.currentUser == null) {
            return '/login';
          } else {
            return '/users/${FirebaseAuth.instance.currentUser?.uid}';
          }
        }),
    GoRoute(
        path: '/users/:userId',
        builder: (BuildContext context, GoRouterState state) {
          return UserMainPage();
        },
        redirect: (BuildContext context, GoRouterState state) {
          if (FirebaseAuth.instance.currentUser == null) {
            return '/login';
          } else {
            return null;
          }
        }),
    GoRoute(
        path: '/game',
        builder: (BuildContext context, GoRouterState state) {
          return const GamePage("game");
        },
        redirect: (BuildContext context, GoRouterState state) {
          if (FirebaseAuth.instance.currentUser == null) {
            return '/login';
          } else {
            return null;
          }
        }),
    GoRoute(
        path: '/howtoplay',
        builder: (BuildContext context, GoRouterState state) {
          return HowToPlay();
        },
        redirect: (BuildContext context, GoRouterState state) {
          if (FirebaseAuth.instance.currentUser == null) {
            return '/login';
          } else {
            return null;
          }
        }),
    GoRoute(
        path: '/testgame',
        builder: (BuildContext context, GoRouterState state) {
          return TicTacToeBoard(
              gameRef: FirebaseDatabase.instance.ref().child('games').push(),
              player: Player('Alice', 'X'));
        }),
    GoRoute(
      path: '/rooms',
      builder: (BuildContext context, GoRouterState state) {
        return RoomList();
      },
    ),
    GoRoute(
      path: '/rooms/:roomid',
      builder: (BuildContext context, GoRouterState state) {
        return GameRoom(
          roomid: state.params['roomid']!,
        );
      },
    ),
    GoRoute(
      path: '/testroom/:roomid',
      builder: (BuildContext context, GoRouterState state) {
        return SyncState(
          roomid: state.params['roomid']!,
        );
      },
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({Key? key}) : super(key: key);

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
                onPressed: () => context.go('/register'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  minimumSize: MaterialStateProperty.all(const Size(240, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(240, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 20),
                    ))),
          ],
        ),
      ),
    );
  }
}
