import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class BachecaRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BachecaRouteState();
  }
}

class _BachecaRouteState extends State<BachecaRoute> {
  List listaBacheca = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsBacheca = <Widget>[];
    for (var elemento in listaBacheca) {
      widgetsBacheca.add(Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: widgetBacheca(elemento, refresh: aggiornaBacheca)));
    }
    return BackdropScaffold(
        title: Text('Bacheca'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaBacheca,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsBacheca))));
  }

  Future aggiornaBacheca() async {
    var nuovaBacheca = await bacheca();
    setState(() {
      listaBacheca = nuovaBacheca;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
