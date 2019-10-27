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
  List voti = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsAssenze = <Widget>[];
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
    /*
    var nuoviVoti = await votigiornalieri();
    var votiAggiornati = [];
    nuoviVoti.forEach(
        (k, v) => votiAggiornati.add({'materia': k, 'voti': v['voti']}));
    setState(() {
      voti = votiAggiornati;
    });
    return votiAggiornati;
    */
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
