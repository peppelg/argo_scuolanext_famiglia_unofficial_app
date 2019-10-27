import 'package:flutter/material.dart';

getBackdrop(context) {
  return Center(
      child: SingleChildScrollView(
          child: Column(children: <Widget>[
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/voti');
      },
      child: Text('I miei voti', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/note');
      },
      child: Text('Note', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/assenze');
      },
      child: Text('Assenze', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/compiti');
      },
      child: Text('Compiti assegnati', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/lezioni');
      },
      child: Text('Argomenti lezione', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/oggi');
      },
      child: Text('Cosa è successo oggi', style: TextStyle(color: Colors.white)),
    ),
    FlatButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/info');
      },
      child: Text('Informazioni', style: TextStyle(color: Colors.white)),
    )
  ])));
}
