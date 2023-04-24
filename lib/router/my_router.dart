import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:othello/how_to_play.dart';
import 'package:othello/room_list.dart';
import 'package:othello/game_room.dart';
import '../main.dart';
import '../login.dart';
import '../register.dart';
import '../user_main_page.dart';

class MyRouter {
  static Future<String?> checkInGame() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    String roomid = "";
    bool isUserInGame = false;
    try {
      await dbRef
          .child('GameRooms')
          .once(DatabaseEventType.value)
          .then((DatabaseEvent databaseEvent) {
        Map<dynamic, dynamic> values = databaseEvent.snapshot.value as Map;
        if (values.isNotEmpty) {
          values.forEach((key, value) {
            // print(FirebaseAuth.instance.currentUser!.uid);
            if (value['players'] != null) {
              if (value['players']['player1'] != null) {
                if (value['players']['player1']['uid'] ==
                    FirebaseAuth.instance.currentUser!.uid && value['winner'].toString().isEmpty) {
                  isUserInGame = true;
                  roomid = key;
                  return;
                }
              }
              if (value['players']['player2'] != null) {
                if (value['players']['player2']['uid'] ==
                    FirebaseAuth.instance.currentUser!.uid && value['winner'].toString().isEmpty) {
                  isUserInGame = true;
                  roomid = key;
                  return;
                }
              }
            }
          });
        }
      });
    } catch (e) {
      return null;
    }
    print('User is in game $isUserInGame');
    return isUserInGame == false ? null : '/rooms/$roomid/';
  }

  static GoRouter returnRouter() => GoRouter(
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
                return const UserMainPage();
              },
              redirect: (BuildContext context, GoRouterState state) async {
                if (FirebaseAuth.instance.currentUser == null) {
                  return '/login';
                } else {
                  return await checkInGame();
                }
              }),
          GoRoute(
              path: '/howtoplay',
              builder: (BuildContext context, GoRouterState state) {
                return const HowToPlay();
              },
              redirect: (BuildContext context, GoRouterState state) async {
                if (FirebaseAuth.instance.currentUser == null) {
                  var isInGame = await checkInGame();
                  return isInGame!.isEmpty ? '/login' : isInGame;
                } else {
                  return null;
                }
              }),
          GoRoute(
              path: '/rooms',
              builder: (BuildContext context, GoRouterState state) {
                return RoomList();
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (FirebaseAuth.instance.currentUser == null) {
                  return '/login';
                } else {
                  return null;
                }
              }),
          GoRoute(
            path: '/rooms/:roomid',
            builder: (BuildContext context, GoRouterState state) {
              return GameRoom(
                roomid: state.params['roomid']!,
              );
            },
          ),
        ],
      );
}
