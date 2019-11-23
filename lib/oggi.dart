import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'backdropWidgets.dart';
import 'api.dart';

class OggiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OggiRouteState();
  }
}

class _OggiRouteState extends State<OggiRoute> {
  List listaOggi = [];
  var giorno = formatDate(DateTime.now().toString());
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsOggi = <Widget>[];
    for (var tipo in listaOggi) {
      widgetsOggi.add(Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(tipo['titolo'] + ' - ' + tipo['tipo']),
              subtitle: Text(tipo['descrizione']),
              //leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.warning)])
            )
          ]))));
    }
    return BackdropScaffold(
        title: Text('Cosa è successo oggi'),
        backLayer: getBackdrop(context),
        iconPosition: BackdropIconPosition.leading,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(2000),
                    maxTime: DateTime.now(), onConfirm: (date) {
                  giorno = formatDate(date.toString());
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _refreshIndicatorKey.currentState.show());
                },
                    currentTime: DateFormat('dd/MM/y').parse(giorno),
                    locale: LocaleType.it);
              })
        ],
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaOggi,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsOggi))));
  }

  Future aggiornaOggi() async {
    var nuovoOggi = await oggi(giorno);
    setState(() {
      listaOggi = nuovoOggi;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
