import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class AssenzeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AssenzeRouteState();
  }
}

class _AssenzeRouteState extends State<AssenzeRoute> {
  List listaAssenze = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsAssenze = <Widget>[];
    for (var assenza in listaAssenze) {
      widgetsAssenze.add(Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: widgetAssenza(assenza)));
    }
    return BackdropScaffold(
        title: Text('Assenze'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaAssenze,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsAssenze))));
  }

  Future aggiornaAssenze() async {
    var nuoveAssenze = await assenze();
    setState(() {
      listaAssenze = nuoveAssenze;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
