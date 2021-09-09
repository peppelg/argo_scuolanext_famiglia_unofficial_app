import 'package:argo_famiglia/widgets.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'dart:async';
import 'backdropWidgets.dart';
import 'api.dart';

class ScrutinioRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScrutinioRouteState();
  }
}

class _ScrutinioRouteState extends State<ScrutinioRoute> {
  var scrutinio = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  generaLista() {
    var tiles = <Widget>[];
    scrutinio.forEach((final idPeriodo, var periodoScrutinio) {
      var votiScrutinio = <Widget>[];
      print('periodoScrutinio => ' + periodoScrutinio.toString());
      for (var voto in periodoScrutinio['dati']) {
        votiScrutinio.add(widgetScrutinio(voto, context));
      }

      tiles.add(ExpansionTile(
          title: Text(periodoScrutinio['titolo']),
          children: votiScrutinio.isNotEmpty
              ? votiScrutinio
              : [new Text('Nessun voto')]));
    });

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    var lista = generaLista();

    return BackdropScaffold(
        title: Text('Voti Scrutinio'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaScrutinio,
            child:
                ListView(children: new List.from(<Widget>[])..addAll(lista))));
  }

  Future aggiornaScrutinio() async {
    var nuoviVoti = await votiscruitinio();
    setState(() {
      scrutinio = nuoviVoti;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
