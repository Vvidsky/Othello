import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../login.dart';
import '../game.dart';
import '../register.dart';
import '../user_main_page.dart';

class MyRouter {
  late final router = GoRouter(routes: [
    // TODO: Add Routes
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
            path: 'users/:userId',
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
          path: 'game',
          builder: (BuildContext context, GoRouterState state) {
            return const GamePage("game");
          },
        ),
      ],
      // TODO: Add Error Handler
      // TODO Add Redirect
    )
  ]);
}
