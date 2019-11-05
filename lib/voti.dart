import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'aggiornamento.dart';

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
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
}
