import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SignUpPage builds its own Navigator which ends up being a nested
    // Navigator in our app.
    return Navigator(
      initialRoute: 'register',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'register/personal_info':
            // Assume CollectPersonalInfoPage collects personal info and then
            // navigates to 'signup/choose_credentials'.
            builder = (BuildContext context) => const CollectPersonalInfoPage();
            break;
          case 'register/choose_credentials':
            // Assume ChooseCredentialsPage collects new credentials and then
            // invokes 'onSignupComplete()'.
            builder = (BuildContext _) => ChooseCredentialsPage(
                  onSignupComplete: () {
                    // Referencing Navigator.of(context) from here refers to the
                    // top level Navigator because SignUpPage is above the
                    // nested Navigator that it created. Therefore, this pop()
                    // will pop the entire "sign up" journey and return to the
                    // "/" route, AKA HomePage.
                    Navigator.of(context).pop();
                  },
                );
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute<void>(builder: builder, settings: settings);
      },
    );
  }
}

class CollectPersonalInfoPage extends StatelessWidget {
  const CollectPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headlineMedium!,
      child: GestureDetector(
        onTap: () {
          // This moves from the personal info page to the credentials page,
          // replacing this page with that one.
          Navigator.of(context)
              .pushReplacementNamed('register/choose_credentials');
        },
        child: Container(
          color: Colors.lightBlue,
          alignment: Alignment.center,
          child: const Text('Collect Personal Info Page'),
        ),
      ),
    );
  }
}

class ChooseCredentialsPage extends StatelessWidget {
  const ChooseCredentialsPage({
    super.key,
    required this.onSignupComplete,
  });

  final VoidCallback onSignupComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSignupComplete,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.headlineMedium!,
        child: Container(
          color: Colors.pinkAccent,
          alignment: Alignment.center,
          child: const Text('Choose Credentials Page'),
        ),
      ),
    );
  }
}