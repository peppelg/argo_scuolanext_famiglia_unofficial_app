import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class CompitiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CompitiRouteState();
  }
}

class _CompitiRouteState extends State<CompitiRoute> {
  Map listaCompiti = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsCompiti = <Widget>[];
    listaCompiti.forEach((k, compiti) => widgetsCompiti.add(ExpansionTile(
        leading: Icon(Icons.assignment),
        title: Text(k),
        children: buildCompitiWidget(compiti))));
    return BackdropScaffold(
        title: Text('Compiti assegnati'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaCompiti,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsCompiti))));
  }

  Future aggiornaCompiti() async {
    var nuoviCompiti = await compiti();
    setState(() {
      listaCompiti = nuoviCompiti;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  buildCompitiWidget(compiti) {
    var widgetCompiti = <Widget>[];
    for (var compito in compiti) {
      widgetCompiti.add(widgetCard(compito['data'], compito['compito']));
    }
    return widgetCompiti;
  }
}
