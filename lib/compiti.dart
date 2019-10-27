import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';

class CompitiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CompitiRouteState();
  }
}

class _CompitiRouteState extends State<CompitiRoute> {
  List voti = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsCompiti = <Widget>[];
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
