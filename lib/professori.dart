import 'package:argo_famiglia/widgets.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'dart:async';
import 'backdropWidgets.dart';
import 'api.dart';
import 'database.dart';

class ProfessoriRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfessoriRouteState();
  }
}

class _ProfessoriRouteState extends State<ProfessoriRoute> {
  var professori = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  generaLista() {
    var out = <Widget>[];
    for (var prof in professori) {
      out.add(widgetProfessore(prof, context));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    var lista = generaLista();

    return BackdropScaffold(
        title: Text('Lista Professori'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaProfessori,
            child: ListView(
              children: new List.from(<Widget>[])..addAll(lista)
            )
        )
    );
  }

  Future aggiornaProfessori() async {
    var nuoviProfessori = await listaProfessori();

    if (nuoviProfessori.isNotEmpty) {
      await Database.put('professori', nuoviProfessori);
    }

    setState(() {
      professori = nuoviProfessori;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
