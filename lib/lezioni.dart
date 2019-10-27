import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';

class LezioniRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LezioniRouteState();
  }
}

class _LezioniRouteState extends State<LezioniRoute> {
  List voti = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsLezioni = <Widget>[];
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
