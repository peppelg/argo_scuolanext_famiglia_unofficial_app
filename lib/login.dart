import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api.dart';
import 'dart:async';
import 'aggiornamento.dart';

/*
class LoginForm extends StatelessWidget {
  final schoolField = TextEditingController();
  final usernameField = TextEditingController();
  final passwordField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(40.0), children: <Widget>[
      Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            controller: schoolField,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Codice scuola',
            ),
          )),
      Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            controller: usernameField,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Username',
            ),
          )),
      Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            controller: passwordField,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          )),
      Padding(
          padding: EdgeInsets.all(20.0),
          child: FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              doLogin(schoolField.text, usernameField.text, passwordField.text).then((value) {
                if (value == 'OK') {
                  //Fluttertoast.showToast(msg: 'Login eseguito.');
                } else {
                  Fluttertoast.showToast(msg: 'Username o password non validi\n\n'+value);
                }
                print('vamos a home');
                return MaterialPageRoute(
                  builder: (context) => GetHome()
                );
                /* da fixare
                print('vamos a home');
                return MaterialPageRoute(
                  builder: (context) => GoHome()
                );
                */
              });
            },
            child: Text(
              "LOGIN",
            ),
          ))
    ]);
  }
}

Future doLogin(school, username, password) async {
  var status = await login(school, username, password);
  return status;
}
*/
class LoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginRouteState();
  }
}

class _LoginRouteState extends State<LoginRoute> {
  final schoolField = TextEditingController();
  final usernameField = TextEditingController();
  final passwordField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    checkUpdatesDialog(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Scuolanext - Login'),
        ),
        body: ListView(padding: const EdgeInsets.all(40.0), children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: schoolField,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Codice scuola',
                ),
              )),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: usernameField,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              )),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: passwordField,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              )),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                onPressed: () {
                  doLogin(context, schoolField.text, usernameField.text,
                      passwordField.text);
                },
                child: Text(
                  'LOGIN',
                ),
              ))
        ]));
  }
}

Future doLogin(context, school, username, password) async {
  var status = await login(school, username, password);
  if (status == 'OK') {
    Fluttertoast.showToast(msg: 'Login eseguito.');
    Navigator.of(context).pushReplacementNamed('/voti');
  } else {
    Fluttertoast.showToast(msg: 'Username o password non validi\n\n' + status);
  }
}
