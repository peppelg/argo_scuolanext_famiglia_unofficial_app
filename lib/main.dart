import 'package:argo_famiglia/aggiornamento.dart';
import 'package:argo_famiglia/debugApi.dart';
import 'package:flutter/material.dart';
import 'redirectRoute.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo Famiglia Unofficial',
      home: RedirectRoute(),
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
