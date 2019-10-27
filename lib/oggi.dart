import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';

class OggiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OggiRouteState();
  }
}

class _OggiRouteState extends State<OggiRoute> {
  List voti = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsOggi = <Widget>[];
    return BackdropScaffold(
        title: Text('Cosa è successo oggi'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaOggi,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsOggi))));
  }

  Future aggiornaOggi() async {
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
