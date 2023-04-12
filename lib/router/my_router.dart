import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:othello/game_room.dart';
import 'package:othello/how_to_play.dart';
import 'package:othello/room_list.dart';
import 'package:othello/test_syncstate.dart';
import '../main.dart';
import '../login.dart';
import '../game.dart';
import '../register.dart';
import '../user_main_page.dart';

class MyRouter {
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
}
