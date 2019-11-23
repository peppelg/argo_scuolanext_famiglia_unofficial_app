import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
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
    var redirectTo = '/voti';
    var quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'open_orario') {
        redirectTo = '/orario';
      }
      if (shortcutType == 'open_oggi') {
        redirectTo = '/oggi';
      }
      if (shortcutType == 'open_compiti') {
        redirectTo = '/compiti';
      }
      if (redirectTo != '/voti') {
        Navigator.of(context).pushReplacementNamed(
            redirectTo); //si put nu altra volta xk x strani motivi funzione run dopo pushreplacementmethod + sotto
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
          type: 'open_orario', localizedTitle: 'Orario', icon: 'timetable'),
      ShortcutItem(
          type: 'open_oggi',
          localizedTitle: 'Cosa è successo oggi',
          icon: 'calendar'),
      ShortcutItem(
          type: 'open_compiti',
          localizedTitle: 'Compiti assegnati',
          icon: 'homework')
    ]);
    Navigator.of(context).pushReplacementNamed(redirectTo);
  } else {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
