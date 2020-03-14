import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  voto = double.parse(voto);
  return CircularPercentIndicator(
    radius: radius,
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

widgetBacheca(elemento) {
  var subtitle = <Widget>[Text(elemento['messaggio'])];
  if (elemento['link'] != null) {
    subtitle.add(FlatButton(
        onPressed: () {
          launch(elemento['link']);
        },
        child: Text(elemento['link'])));
  }
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(
        title: Text(elemento['oggetto'] + ' - ' + elemento['data']),
        subtitle: Column(
            children: subtitle, crossAxisAlignment: CrossAxisAlignment.start))
  ]));
}

widgetOggiDynamic(tipo, elementi, context) {
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
      widgets.add(widgetBacheca(elemento['elemento']));
    }
  }
  return widgets;
}
