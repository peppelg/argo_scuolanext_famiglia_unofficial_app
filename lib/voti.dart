import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'aggiornamento.dart';
import 'database.dart';
import 'widgets.dart';

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
      var media = mediaVoti(materia['voti']);
      var widgetsVoti = <Widget>[
        Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                  child: Column(children: <Widget>[
                cerchioVoto(media['orale'], radius: 60.0),
                Opacity(opacity: 0.6, child: Text('Media orale'))
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                cerchioVoto(media['scritto'], radius: 60.0),
                Opacity(opacity: 0.6, child: Text('Media scritto'))
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                cerchioVoto(media['pratico'], radius: 60.0),
                Opacity(opacity: 0.6, child: Text('Media pratico'))
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                cerchioVoto(media['ScrittoOrale'], radius: 60.0),
                Opacity(opacity: 0.6, child: Text('Media totale'))
              ])),
            ]),
        Divider()
      ];
      for (var voto in materia['voti']) {
        widgetsVoti.add(widgetVoto(voto, context));
      }
      widgetsMaterie.add(ExpansionTile(
          leading: cerchioVoto(media['globale']),
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
    if (nuoviVoti.isNotEmpty) {
      await Database.put('voti', nuoviVoti);
    }
    var settings = await Database.get('settings');
    if (settings.containsKey('dateFilter') && settings['dateFilter'] != null) {
      nuoviVoti = filtraVoti(nuoviVoti, settings['dateFilter']);
    }
    setState(() {
      voti = nuoviVoti;
    });
  }

  filtraVoti(voti, data) {
    Map.from(voti).forEach((nomeMateria, materia) {
      for (var voto in List.from(materia['voti'])) {
        var dataVoto = DateFormat('dd/MM/y').parse(voto['data']);
        if (dataVoto.isBefore(data)) {
          voti[nomeMateria]['voti'].remove(voto);
        }
      }
    });
    return voti;
  }

  mediaVoti(listaVoti) {
    //magno spaghetti
    var risultato = {};
    var medie = {
      'globale': {'numeroVoti': 0, 'sommaVoti': 0.0},
      'scritto': {'numeroVoti': 0, 'sommaVoti': 0.0},
      'orale': {'numeroVoti': 0, 'sommaVoti': 0.0},
      'pratico': {'numeroVoti': 0, 'sommaVoti': 0.0},
      'ScrittoOrale': {'numeroVoti': 0, 'sommaVoti': 0.0}
    };
    for (var voto in listaVoti) {
      if (!voto['commento'].contains('non fa media') &&
          double.parse(voto['voto'].toString()) > 0) {
        double valore = 100;
        if (voto['commento'].contains('incide al')) {
          RegExp regex = new RegExp(r"(\d+)(?!.*\d)");
          valore = double.parse(regex.allMatches(voto['commento']).first[0].replaceAll(',', '.'));
        }
        print("Valore: " + valore.toString());
        medie['globale']['numeroVoti'] += valore;
        medie['globale']['sommaVoti'] += double.parse(voto['voto'].toString()) * valore;
        if (medie.containsKey(voto['tipo'])) {
          medie[voto['tipo']]['numeroVoti'] += valore;
          medie[voto['tipo']]['sommaVoti'] +=
              double.parse(voto['voto'].toString()) * valore;
        }
      }
    }
    medie.forEach((tipo, media) {
      var mediaVoto =
          (media['sommaVoti'] / media['numeroVoti']).toStringAsFixed(2);
      if (mediaVoto == 'NaN') {
        mediaVoto = '0';
      }
      risultato[tipo] = mediaVoto;
    });
    //fa media scritto e orale
    if (double.parse(risultato['orale']) > 0) {
      medie['ScrittoOrale']['numeroVoti']++;
      medie['ScrittoOrale']['sommaVoti'] += double.parse(risultato['orale']);
    }
    if (double.parse(risultato['scritto']) > 0) {
      medie['ScrittoOrale']['numeroVoti']++;
      medie['ScrittoOrale']['sommaVoti'] += double.parse(risultato['scritto']);
    }
    if (double.parse(risultato['pratico']) > 0) {
      medie['ScrittoOrale']['numeroVoti']++;
      medie['ScrittoOrale']['sommaVoti'] += double.parse(risultato['pratico']);
    }
    var mediaVoto = (medie['ScrittoOrale']['sommaVoti'] /
            medie['ScrittoOrale']['numeroVoti'])
        .toStringAsFixed(2);
    if (mediaVoto == 'NaN') {
      mediaVoto = '0';
    }
    risultato['ScrittoOrale'] = mediaVoto;
    return risultato;
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
  try {
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
      //votiAttuali = ['6.0 di cosita (Prof. testings) del 20/09/2019'];
      for (var voto in nuoviVoti) {
        if (!votiAttuali.contains(voto)) {
          var testoNotifica = 'Hai preso un ' + voto;
          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'nuovo-voto',
              'Notifica voto',
              'Notifica nuovi voti su Argo ScuolaNext.',
              groupKey: 'com.peppelg.argo_famiglia.NOTIFICHEVOTO',
              styleInformation: BigTextStyleInformation(testoNotifica));
          var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(nuoviVoti.indexOf(voto),
              'Nuovo voto', testoNotifica, platformChannelSpecifics,
              payload: voto);
        }
      }
    }
  } catch (e) {}
}
