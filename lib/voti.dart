import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'aggiornamento.dart';
import 'database.dart';

class VotiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VotiRouteState();
  }
}

class _VotiRouteState extends State<VotiRoute> {
  Map voti = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    checkUpdatesDialog(context);
    var widgetsMaterie = <Widget>[];
    voti.forEach((nomeMateria, materia) {
      var widgetsVoti = <Widget>[];
      for (var voto in materia['voti']) {
        widgetsVoti.add(schedaVoto(voto));
      }
      widgetsMaterie.add(ExpansionTile(
          leading: cerchioVoto(mediaVoti(materia['voti'])),
          title: Text(nomeMateria),
          children: widgetsVoti));
    });

    return BackdropScaffold(
        title: Text('I miei voti'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaVoti,
            child: ListView(
                children: new List.from(<Widget>[
              /*
              Text('cosita'),
              FlatButton(
                  child: Text('aaa'),
                  onPressed: () {
                    aggiornaVoti();
                  })
                  */
            ])
                  ..addAll(widgetsMaterie))));
  }

  Future aggiornaVoti() async {
    var nuoviVoti = await votigiornalieri();
    setState(() {
      voti = nuoviVoti;
    });
    if (nuoviVoti.isNotEmpty) {
      await Database.put('voti', nuoviVoti);
    }
  }

  schedaVoto(voto) {
    return Padding(
        padding: EdgeInsets.only(left: 5, top: 5),
        child: ListTile(
            leading: cerchioVoto(voto['voto'].toString()),
            title: Text(voto['tipo']),
            subtitle: Text(voto['data']),
            trailing: IconButton(
              icon: Icon(Icons.info_outline),
              tooltip: 'Visualizza altre informazioni',
              onPressed: () {
                return showDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Informazioni sul voto'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Voto: ' + voto['voto'].toString()),
                            Text('Data: ' + voto['data']),
                            Text('Descrizione: ' +
                                (['', null, false, 0]
                                        .contains(voto['descrizione'])
                                    ? '<nessuna descrizione>'
                                    : voto['descrizione']) +
                                ' ' +
                                voto['commento'])
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Chiudi'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )));
  }

  cerchioVoto(voto) {
    voto = double.parse(voto);
    return CircularPercentIndicator(
      radius: 40.0,
      lineWidth: 5.0,
      percent: voto / 10,
      center: Text(voto.toString()),
      progressColor: coloreVoto(voto.toString()),
    );
  }

  coloreVoto(voto) {
    voto = double.parse(voto);
    if (voto <= 0) {
      return Colors.white;
    }
    if (voto >= 6) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  mediaVoti(listaVoti) {
    double sommaVoti = 0;
    int numeroVoti = 0;
    for (var voto in listaVoti) {
      if (!voto['commento'].contains('non fa media')) {
        numeroVoti++;
        sommaVoti += double.parse(voto['voto'].toString());
      }
    }
    var mediaVoti = (sommaVoti / numeroVoti).toStringAsFixed(2);
    if (mediaVoti == 'NaN') {
      mediaVoti = '0';
    }
    return mediaVoti;
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}

semplificaVoti(listaVoti) {
  //che cacata
  var lista = [];
  listaVoti.forEach((nomeMateria, materia) {
    for (var voto in materia['voti']) {
      lista.add(voto['voto'].toString() +
          ' di ' +
          nomeMateria +
          ' del ' +
          voto['data']);
    }
  });
  return lista;
}

Future notificaNuoviVoti() async {
  await loadToken(); //fa login
  //flutter plugin notificazione
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('homework');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //fine cacata
  //cerca voti nuovi
  var votiAttuali = await Database.get('voti');
  var nuoviVoti = await votigiornalieri();
  if (votiAttuali.isNotEmpty && nuoviVoti.isNotEmpty) {
    await Database.put('voti', nuoviVoti);
    votiAttuali = semplificaVoti(votiAttuali);
    nuoviVoti = semplificaVoti(nuoviVoti);
    /*
    votiAttuali = [
      '6.0 di cosita (Prof. testings) del 20/09/2019'
    ];
    */
    for (var voto in nuoviVoti) {
      if (!votiAttuali.contains(voto)) {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'nuovo-voto',
            'Notifica voto',
            'Notifica nuovi voti su Argo ScuolaNext.',
            groupKey: 'nuovo-voto');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin.show(nuoviVoti.indexOf(voto),
            'Nuovo voto', 'Hai preso un ' + voto, platformChannelSpecifics,
            payload: voto);
      }
    }
  }
}
