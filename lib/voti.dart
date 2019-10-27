import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';

class VotiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VotiRouteState();
  }
}

class _VotiRouteState extends State<VotiRoute> {
  List voti = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsMaterie = <Widget>[];
    for (var materia in voti) {
      var listaVoti = <Widget>[];
      double sommaVoti = 0;
      int numeroVoti = 0;
      for (var voto in materia['voti']) {
        voto[0] = voto[0].toString();
        if (!voto[3].contains('non fa media')) {
          sommaVoti += double.parse(voto[0]);
          numeroVoti++;
        }
        listaVoti.add(Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: ListTile(
                leading: CircleAvatar(
                    child: Text(voto[0].toString()),
                    backgroundColor: coloreVoto(voto[0])),
                title: Text(voto[2]),
                subtitle: Text(voto[1]),
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
                                Text('Voto: ' + voto[0]),
                                Text('Data: ' + voto[1]),
                                Text('Descrizione: ' +
                                    (['', null, false, 0].contains(voto[4])
                                        ? '<nessuna descrizione>'
                                        : voto[4]) +
                                    ' ' +
                                    voto[
                                        3]) //4 descrizione sul compito, 3 descrizione breve, ci può essere non fa media
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
                )))); //voto[1] data, voto[2] scritto o orale
      }
      var mediaVoti = (sommaVoti / numeroVoti).toStringAsFixed(2);
      if (mediaVoti == 'NaN') {
        mediaVoti = '0';
      }
      widgetsMaterie.add(ExpansionTile(
          leading: CircleAvatar(
              child: Text(mediaVoti), backgroundColor: coloreVoto(mediaVoti)),
          title: Text(materia['materia']),
          children: listaVoti));
    }
    return BackdropScaffold(
        title: Text('I miei voti'),
        backLayer: getBackdrop(context),
        /*
        iconPosition: BackdropIconPosition.leading, //poi lo uso x fare bottone x change data
          actions: <Widget>[
            BackdropToggleButton(
              icon: AnimatedIcons.list_view,
            ),
          ],
          */
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
    var votiAggiornati = [];
    nuoviVoti.forEach(
        (k, v) => votiAggiornati.add({'materia': k, 'voti': v['voti']}));
    setState(() {
      voti = votiAggiornati;
    });
    return votiAggiornati;
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
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
