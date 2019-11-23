import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'redirectRoute.dart';
import 'database.dart';
import 'login.dart';
import 'voti.dart';
import 'assenze.dart';
import 'compiti.dart';
import 'lezioni.dart';
import 'note.dart';
import 'oggi.dart';
import 'orario.dart';
import 'info.dart';
import 'debugApi.dart';
import 'aggiornamento.dart';
import 'impostazioni.dart';

var theme;

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    await notificaNuoviVoti();
    return Future.value(true);
  });
}

Future main() async {
  var settings = await Database.get('settings');
  if (settings == null) {
    settings = {'notifications': false, 'dark': false};
  }
  if (settings['dark'] == true) {
    theme = ThemeData(
      brightness: Brightness.dark,
    );
  } else {
    theme = ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ));
  }
  if (settings['notifications'] == true) {
    Workmanager.initialize(callbackDispatcher);
    Workmanager.registerPeriodicTask('controllaVoti', 'controllaVoti',
        frequency: Duration(hours: 1, minutes: 30));
  } else {
    try {
      Workmanager.cancelAll();
    } catch (e) {}
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo Famiglia Unofficial',
      home: RedirectRoute(),
      theme: theme,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      onGenerateRoute: (settings) {
        var route;
        switch (settings.name) {
          case '/voti':
            {
              route = VotiRoute();
            }
            break;
          case '/login':
            {
              route = LoginRoute();
            }
            break;
          case '/note':
            {
              route = NoteRoute();
            }
            break;
          case '/assenze':
            {
              route = AssenzeRoute();
            }
            break;
          case '/compiti':
            {
              route = CompitiRoute();
            }
            break;
          case '/lezioni':
            {
              route = LezioniRoute();
            }
            break;
          case '/oggi':
            {
              route = OggiRoute();
            }
            break;
          case '/orario':
            {
              route = OrarioRoute();
            }
            break;
          case '/info':
            {
              route = InfoRoute();
            }
            break;
          case '/debugApi':
            {
              route = DebugApiRoute();
            }
            break;
          case '/aggiornamento':
            {
              route = AggiornamentoRoute();
            }
            break;
          case '/impostazioni':
            {
              route = ImpostazioniRoute();
            }
            break;
        }
        return PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => route,
          transitionsBuilder: (context, anim1, anim2, child) {
            return FadeTransition(opacity: anim1, child: child);
          },
        );
      },
    );
  }
}
