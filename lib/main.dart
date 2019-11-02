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

/*void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo Famiglia Unofficial',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scuolanext - Login'),
        ),
        body: GetBody(),
      ),
    );
  }
}

/*
esempio statelesswidget
class LoadMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Hello World'),
    );
  }
}
*/
class GetBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginForm();
  }
}
*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo Famiglia Unofficial',
      home: RedirectRoute(),
      routes: <String, WidgetBuilder>{
        '/voti': (BuildContext context) => new VotiRoute(),
        '/login': (BuildContext context) => new LoginRoute(),
        '/note': (BuildContext context) => new NoteRoute(),
        '/assenze': (BuildContext context) => new AssenzeRoute(),
        '/compiti': (BuildContext context) => new CompitiRoute(),
        '/lezioni': (BuildContext context) => new LezioniRoute(),
        '/oggi': (BuildContext context) => new OggiRoute(),
        '/orario': (BuildContext context) => new OrarioRoute(),
        '/info': (BuildContext context) => new InfoRoute(),
        '/debugApi': (BuildContext context) => new DebugApiRoute(),
        '/aggiornamento': (BuildContext context) => new AggiornamentoRoute()
      },
    );
  }
}
