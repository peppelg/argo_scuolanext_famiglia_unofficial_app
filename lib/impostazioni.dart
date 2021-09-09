import 'package:flutter/material.dart';
import 'dart:async';
import 'package:background_fetch/background_fetch.dart';
import 'package:backdrop/backdrop.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:restart_app/restart_app.dart';
import 'backdropWidgets.dart';
import 'database.dart';
import 'api.dart';
import 'main.dart' as mainVar;

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
  var settings_dateFilterToggle = false;
  var settings_dateFilter = null;
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
                            keyboardType: TextInputType.number,
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
          title: Text('Tema scuro'),
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
    widgetsImpostazioni.add(
      Card(
        child: SwitchListTile(
          title: Text('Filtra voti'),
          value: settings_dateFilterToggle,
          onChanged: (bool value) async {
            if (settings_dateFilterToggle == false) {
              //apre coso x impostare data
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2000),
                  maxTime: DateTime.now(), onConfirm: (date) async {
                setState(() {
                  settings_dateFilter = date;
                  settings_dateFilterToggle = value;
                });
                Fluttertoast.showToast(
                    msg: 'Verranno mostrati solo i voti registrati dopo il ' +
                        date.toString());
                await aggiornaImpostazioni();
              }, currentTime: settings_dateFilter, locale: LocaleType.it);
            } else {
              //toglie filtro
              setState(() {
                settings_dateFilterToggle = value;
                settings_dateFilter = null;
              });
              await aggiornaImpostazioni();
            }
          },
          secondary: Icon(Icons.date_range),
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
    widgetsImpostazioni.add(Card(
        child: ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text(
                        'Vuoi resettare tutti i dati dell\'applicazione?'),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text('Sì'),
                        onPressed: () async {
                          await Database.resetDatabase();
                          Restart.restartApp();
                        },
                      ),
                    ],
                  );
                },
              );
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
    settings['dateFilter'] = settings_dateFilter;
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
    mainVar.darkTheme = settings['dark'];
    runApp(mainVar.MyApp());
    //Fluttertoast.showToast(msg: 'Riavvia l\'app per applicare le modifiche.');
  }

  Future visualizzaImpostazioni() async {
    settings = await Database.get('settings');
    if (settings == null) {
      settings = {
        'notifications': false,
        'dark': false,
        'notifications_check_interval': 60,
        'dateFilter': null
      };
      await Database.put('settings', settings);
    }
    if (!settings.containsKey('notifications_check_interval')) {
      settings['notifications_check_interval'] = 60;
    }
    if (!settings.containsKey('dateFilter')) {
      settings['dateFilter'] = null;
    }
    setState(() {
      settings_notifications = settings['notifications'];
      settings_dark = settings['dark'];
      intervalloNotificheController.text =
          settings['notifications_check_interval'].toString();
      if (settings['dateFilter'] == null) {
        settings_dateFilter = settings['dateFilter'];
        settings_dateFilterToggle = false;
      } else {
        settings_dateFilter = settings['dateFilter'];
        settings_dateFilterToggle = true;
      }
    });
  }

  void initState() {
    super.initState();
    visualizzaImpostazioni();
  }
}
