import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

getBackdrop(context) {
  return Center(
      child: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/voti');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.pen,
                                color: Colors.white, size: 18.0)),
                        Text('I miei voti',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/orario');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.clock,
                                color: Colors.white, size: 18.0)),
                        Text('Orario',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/assenze');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.userTimes,
                                color: Colors.white, size: 18.0)),
                        Text('Assenze',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/note');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.frown,
                                color: Colors.white, size: 18.0)),
                        Text('Note',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/compiti');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.book,
                                color: Colors.white, size: 18.0)),
                        Text('Compiti assegnati',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/lezioni');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.chalkboardTeacher,
                                color: Colors.white, size: 18.0)),
                        Text('Argomenti lezione',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/oggi');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.calendarDay,
                                color: Colors.white, size: 18.0)),
                        Text('Cosa è successo oggi',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                )),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/impostazioni');
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(FontAwesomeIcons.cog,
                                color: Colors.white, size: 18.0)),
                        Text('Impostazioni',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0))
                      ]),
                ))
              ])));
}
