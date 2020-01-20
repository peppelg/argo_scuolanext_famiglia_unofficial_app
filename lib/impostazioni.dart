import 'package:flutter/material.dart';
import 'dart:async';
import 'package:background_fetch/background_fetch.dart';
import 'package:backdrop/backdrop.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'backdropWidgets.dart';
import 'database.dart';
import 'api.dart';

class ImpostazioniRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImpostazioniRouteState();
  }
}

class _ImpostazioniRouteState extends State<ImpostazioniRoute> {
  var settings;
  var settings_notifications = false;
  var settings_dark = false;
  final intervalloNotificheController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var widgetsImpostazioni = <Widget>[];
    widgetsImpostazioni.add(
      Card(
        child: SwitchListTile(
          title: Text('Notifiche nuovi voti (beta)'),
          value: settings_notifications,
          onChanged: (bool value) async {
            if (value == true) {
              await showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(
                            'Ogni quanti minuti devo controllare se ci sono nuovi voti? (minimo 15 minuti)'),
                        content: SingleChildScrollView(
                            child: ListBody(children: <Widget>[
                          TextField(
                            controller: intervalloNotificheController,
                            obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Minuti',
                            ),
                          )
                        ])),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Salva'),
                            onPressed: () async {
                              if (isNumeric(
                                      intervalloNotificheController.text) &&
                                  int.parse(
                                          intervalloNotificheController.text) >=
                                      15) {
                                Navigator.of(context).pop();
                                setState(() {
                                  settings_notifications = value;
                                });
                                await aggiornaImpostazioni();
                              } else {
                                //numero non valido
                                intervalloNotificheController.text = '60';
                              }
                            },
                          ),
                        ]);
                  });
            } else {
              setState(() {
                settings_notifications = value;
              });
              await aggiornaImpostazioni();
            }
          },
          secondary: Icon(Icons.notifications),
        ),
      ),
    );
    widgetsImpostazioni.add(
      Card(
        child: SwitchListTile(
          title: Text('Tema nero'),
          value: settings_dark,
          onChanged: (bool value) async {
            setState(() {
              settings_dark = value;
            });
            await aggiornaImpostazioni();
          },
          secondary: Icon(Icons.brush),
        ),
      ),
    );
    widgetsImpostazioni.add(Card(
        child: ListTile(
            title: Text('Verifica aggiornamenti'),
            leading: Icon(Icons.update),
            onTap: () {
              Navigator.of(context).pushNamed('/aggiornamento');
            })));
    widgetsImpostazioni.add(Card(
        child: ListTile(
            title: Text('Informazioni'),
            leading: Icon(Icons.info_outline),
            onTap: () {
              Navigator.of(context).pushNamed('/info');
            })));
    return BackdropScaffold(
        title: Text('Impostazioni'),
        backLayer: getBackdrop(context),
        frontLayer: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
                children: new List.from(<Widget>[])
                  ..addAll(widgetsImpostazioni))));
  }

  Future aggiornaImpostazioni() async {
    settings['notifications'] = settings_notifications;
    settings['dark'] = settings_dark;
    settings['notifications_check_interval'] =
        int.parse(intervalloNotificheController.text);
    await Database.put('settings', settings);
    if (settings['notifications'] == true) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
    Fluttertoast.showToast(msg: 'Riavvia l\'app per applicare le modifiche.');
  }

  Future visualizzaImpostazioni() async {
    settings = await Database.get('settings');
    if (settings == null) {
      settings = {
        'notifications': false,
        'dark': false,
        'notifications_check_interval': 60
      };
      await Database.put('settings', settings);
    }
    if (!settings.containsKey('notifications_check_interval')) {
      settings['notifications_check_interval'] = 60;
    }
    setState(() {
      settings_notifications = settings['notifications'];
      settings_dark = settings['dark'];
      intervalloNotificheController.text =
          settings['notifications_check_interval'].toString();
    });
  }

  void initState() {
    super.initState();
    visualizzaImpostazioni();
  }
}
