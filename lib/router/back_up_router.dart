import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:go_router/go_router.dart';
import '../main.dart';
import '../login.dart';
import '../game.dart';
import '../register.dart';
import '../user_main_page.dart';

class LoggedInStateInfo extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }
}

GoRouter routerGenerator(LoggedInStateInfo loggedInState) {
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: loggedInState,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnLogin = state.location == Routes.login;
      final isOnSignUp = state.location == Routes.signup;
      final isLoggedIn = loggedInState.isLoggedIn;

      if (!isOnLogin && !isOnSignUp && !isLoggedIn) return Routes.login;
      if ((isOnLogin || isOnSignUp) && isLoggedIn) return Routes.home;
      return null;
    },
    routes: [
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
            return const UserMainPage();
          },
        ),
        GoRoute(
          path: 'game',
          builder: (BuildContext context, GoRouterState state) {
            return const GamePage("game");
          },
        ),
      ],
    ),
    ],
  );
}

abstract class Routes {
  static const home = '/';
  static const signup = '/register';
  static const login = '/login';
}