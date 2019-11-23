import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:workmanager/workmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'backdropWidgets.dart';
import 'database.dart';

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
  @override
  Widget build(BuildContext context) {
    var widgetsImpostazioni = <Widget>[];
    widgetsImpostazioni.add(
      Card(
        child: SwitchListTile(
          title: Text('Notifiche nuovi voti (beta)'),
          value: settings_notifications,
          onChanged: (bool value) async {
            setState(() {
              settings_notifications = value;
            });
            await aggiornaImpostazioni();
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
    await Database.put('settings', settings);
    if (settings['notifications'] == false) {
      try {
        Workmanager.cancelAll();
      } catch (e) {}
    }
    Fluttertoast.showToast(msg: 'Riavvia l\'app per applicare le modifiche.');
  }

  Future visualizzaImpostazioni() async {
    settings = await Database.get('settings');
    if (settings == null) {
      settings = {'notifications': false, 'dark': false};
      await Database.put('settings', settings);
    }
    setState(() {
      settings_notifications = settings['notifications'];
      settings_dark = settings['dark'];
    });
  }

  void initState() {
    super.initState();
    visualizzaImpostazioni();
  }
}
