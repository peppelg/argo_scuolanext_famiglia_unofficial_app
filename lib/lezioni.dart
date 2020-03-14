import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class LezioniRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LezioniRouteState();
  }
}

class _LezioniRouteState extends State<LezioniRoute> {
  Map listaArgomenti = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsLezioni = <Widget>[];
    listaArgomenti.forEach((k, argomenti) => widgetsLezioni.add(ExpansionTile(
        leading: Icon(Icons.book),
        title: Text(k),
        children: buildArgomentiWidget(argomenti))));
    return BackdropScaffold(
        title: Text('Argomenti lezione'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaLezioni,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsLezioni))));
  }

  Future aggiornaLezioni() async {
    var nuoviArgomenti = await argomenti();
    setState(() {
      listaArgomenti = nuoviArgomenti;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  buildArgomentiWidget(argomenti) {
    var widgetArgomenti = <Widget>[];
    for (var argomento in argomenti) {
      widgetArgomenti
          .add(widgetCard(argomento['data'], argomento['argomento']));
    }
    return widgetArgomenti;
  }
}
