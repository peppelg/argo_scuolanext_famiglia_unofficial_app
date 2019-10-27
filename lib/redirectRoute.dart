import 'package:flutter/material.dart';
import 'api.dart';

class RedirectRoute extends StatelessWidget {
  Widget build(BuildContext context) {
    tryLogin(context);
    return Scaffold(
        body: Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ));
  }
}

Future tryLogin(context) async {
  var loggedIn = await loadToken();
  if (loggedIn == 'OK') {
    Navigator.of(context).pushReplacementNamed('/voti');
  } else {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}