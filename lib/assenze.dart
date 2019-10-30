import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';

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
          child: Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
                title: Text(assenza['assenza'] +
                    (assenza['giustificata'] == true
                        ? ''
                        : ' (da giustificare)')),
                subtitle: Text(assenza['prof']),
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon((assenza['giustificata'] == true
                          ? Icons.assignment_turned_in
                          : Icons.assignment_late))
                    ]))
          ]))));
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
