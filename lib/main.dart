import 'package:flutter/material.dart';
import 'login.dart';
import 'voti.dart';
import 'redirectRoute.dart';

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
        '/login': (BuildContext context) => new LoginRoute()
      },
    );
  }
}
