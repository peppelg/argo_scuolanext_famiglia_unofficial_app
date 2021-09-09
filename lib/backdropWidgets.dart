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
                widgetMenuBottone(
                    'I miei voti',
                    '/voti',
                    Icon(FontAwesomeIcons.pen,
                         color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Orario',
                    '/orario',
                    Icon(FontAwesomeIcons.clock,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Assenze',
                    '/assenze',
                    Icon(FontAwesomeIcons.userTimes,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Note',
                    '/note',
                    Icon(FontAwesomeIcons.frown,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Compiti assegnati',
                    '/compiti',
                    Icon(FontAwesomeIcons.book,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Argomenti lezione',
                    '/lezioni',
                    Icon(FontAwesomeIcons.chalkboardTeacher,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Bacheca',
                    '/bacheca',
                    Icon(FontAwesomeIcons.fileAlt,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Dati anagrafici',
                    '/datianagrafici',
                    Icon(FontAwesomeIcons.info,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Scrutinio',
                    '/scrutinio',
                    Icon(FontAwesomeIcons.thumbtack,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Cosa è successo oggi',
                    '/oggi',
                    Icon(FontAwesomeIcons.calendarDay,
                        color: Colors.white, size: 18.0),
                    context),
                widgetMenuBottone(
                    'Impostazioni',
                    '/impostazioni',
                    Icon(FontAwesomeIcons.cog,
                         color: Colors.white, size: 18.0),
                    context)
              ])));
}

widgetMenuBottone(testo, route, icon, context) {
  return Expanded(
      child: FlatButton(
    onPressed: () {
      Navigator.of(context).pushReplacementNamed(route);
    },
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Padding(padding: EdgeInsets.only(right: 10.0), child: icon),
      Text(testo, style: TextStyle(color: Colors.white, fontSize: 18.0))
    ]),
  ));
}
