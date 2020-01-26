import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:background_fetch/background_fetch.dart';
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

var darkTheme = false;

void backgroundFetchHeadlessTask() async {
  await notificaNuoviVoti();
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish();
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var settings = await Database.get('settings');
  if (settings == null) {
    settings = {
      'notifications': false,
      'dark': false,
      'notifications_check_interval': 60
    };
  }
  BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval:
              settings.containsKey('notifications_check_interval')
                  ? settings['notifications_check_interval']
                  : 60,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
          requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_ANY),
      () async {
    print('[BackgroundFetch] Event received');
    await notificaNuoviVoti();
    BackgroundFetch.finish();
  });
  if (settings['notifications'] == true) {
    BackgroundFetch.start().then((int status) {
      print('[BackgroundFetch] start success: $status');
    });
  } else {
    BackgroundFetch.stop().then((int status) {
      print('[BackgroundFetch] stop success: $status');
    });
  }
  darkTheme = settings['dark'];
  runApp(MyApp());
  settings = await Database.get('settings');
  if (settings['notifications'] == true) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo Famiglia Unofficial',
      home: RedirectRoute(),
      theme:
          ThemeData(brightness: darkTheme ? Brightness.dark : Brightness.light),
      /*
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      */
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
