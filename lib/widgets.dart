import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api.dart';

widgetAssenza(assenza) {
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(
        title: Text(assenza['assenza'] +
            (assenza['giustificata'] == true ? '' : ' (da giustificare)')),
        subtitle: Text(assenza['prof']),
        leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon((assenza['giustificata'] == true
                  ? Icons.assignment_turned_in
                  : Icons.assignment_late))
            ]))
  ]));
}

widgetCard(title, subtitle) {
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(title: Text(title), subtitle: Text(subtitle))
  ]));
}

widgetNota(nota) {
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(
        title: Text(nota['data'] + ' ' + nota['prof']),
        subtitle: Text(nota['nota']),
        leading: Column(
          children: <Widget>[Icon(Icons.warning)],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ))
  ]));
}

cerchioVoto(voto, {radius = 40.0}) {
  var votoAsDouble = double.tryParse(voto) ?? 10; // Per le materie dove il voto non è numerico
  return CircularPercentIndicator(
    radius: radius,
    lineWidth: 5.0,
    percent: votoAsDouble / 10,
    center: Text(voto),
    progressColor: coloreVoto(votoAsDouble),
  );
}

coloreVoto(voto) {
  if (voto <= 0) {
    return Colors.white;
  } else if (voto >= 6) {
    return Colors.green;
  } else if (voto >= 5 && voto < 6) {
    //5
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

widgetVoto(voto, context) {
  return Padding(
      padding: EdgeInsets.only(left: 5, top: 5),
      child: ListTile(
          leading: cerchioVoto(voto['voto'].toString()),
          title: Text(voto['tipo']),
          subtitle: ListBody(
            children: [
              Text(voto['data']),
              Text('validità: ' + (voto['commento'].contains('incide al') ? new RegExp(r"(\d+)(?!.*\d)").allMatches(voto['commento']).first[0] + "%" : "100%"))
            ]
          ),
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

widgetScrutinio(voto, context) {
  return Padding(
      padding: EdgeInsets.only(left: 5, top: 5),
      child: ListTile(
          leading: cerchioVoto(voto['votoOrale']['codVoto']),
          title: Text(voto['desMateria']),
          subtitle: ListBody(children: [
            Text((voto['assenze'] ?? 0).toString() + ' assenze')
          ])
      )
    );
}

widgetBacheca(elemento, {var refresh}) {
  var subtitle = <Widget>[Text(elemento['messaggio'])];
  var buttons = <Widget>[];
  if (elemento['link'] != null) {
    subtitle.add(FlatButton(
        onPressed: () {
          launch(elemento['link']);
        },
        child: Text(elemento['link'])));
  }
  for (var allegato in elemento['allegati']) {
    //desFile: testo file, prgMessaggio: id messaggio, prgAllegato: id allegato
    subtitle.add(FlatButton(
        onPressed: () async {
          launch(getUrl(allegato['prgAllegato'], allegato['prgMessaggio']));
        },
        child: Text(allegato['desFile'])));
  }
  if (elemento['richiedi_presa_visione']) {
    if (elemento['presa_visione']) {
      buttons.add(Expanded(
          child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                Fluttertoast.showToast(msg: 'Hai già preso visione!');
              },
              child: Text('Presa visione confermata'))));
    } else {
      buttons.add(Expanded(
          child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                await presaVisioneBacheca(true, elemento['id'], refresh);
              },
              child: Text('Conferma presa visione'))));
    }
  }
  if (elemento['richiedi_presa_adesione']) {
    if (elemento['presa_adesione']) {
      buttons.add(Expanded(
          child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                await presaVisioneBacheca(false, elemento['id'], refresh);
              },
              child: Text('Rimuovi presa adesione'))));
    } else {
      buttons.add(Expanded(
          child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                await presaVisioneBacheca(false, elemento['id'], refresh);
              },
              child: Text('Conferma presa adesione'))));
    }
  }
  subtitle.add(Row(children: buttons));
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(
        title: Text(elemento['oggetto'] + ' - ' + elemento['data']),
        subtitle: Column(
            children: subtitle, crossAxisAlignment: CrossAxisAlignment.start))
  ]));
}

Future presaVisioneBacheca(presaVisione, id, refresh) async {
  var conferma = await confermaPresaVisione(presaVisione, id);
  Fluttertoast.showToast(msg: conferma['message']);
  await refresh();
}

widgetOggiDynamic(tipo, elementi, context, {var refresh}) {
  var widgets = <Widget>[];
  for (var elemento in elementi) {
    if (tipo == 'Voti') {
      //WIDGET VOTO
      elemento['elemento']['tipo'] = elemento['materia'];
      widgets.add(widgetVoto(elemento['elemento'], context));
    }
    if (tipo == 'Compiti') {
      //WIDGET COMPITI
      widgets.add(
          widgetCard(elemento['materia'], elemento['elemento']['compito']));
    }
    if (tipo == 'Argomenti') {
      //WIDGET ARGOMENTI
      widgets.add(
          widgetCard(elemento['materia'], elemento['elemento']['argomento']));
    }
    if (tipo == 'Note') {
      //WIDGET NOTE
      widgets.add(widgetNota(elemento['elemento']));
    }
    if (tipo == 'Assenze') {
      //WIDGET ASSENZE
      widgets.add(widgetAssenza(elemento['elemento']));
    }
    if (tipo == 'Bacheca') {
      //WIDGET BACHECA
      widgets.add(widgetBacheca(elemento['elemento'], refresh: refresh));
    }
  }
  return widgets;
}
