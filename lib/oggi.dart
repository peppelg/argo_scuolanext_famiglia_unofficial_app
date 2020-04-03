import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class OggiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OggiRouteState();
  }
}

class _OggiRouteState extends State<OggiRoute> {
  Map listaOggi = {};
  var giorno = formatDate(DateTime.now().toString());
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsOggi = <Widget>[];
    listaOggi.forEach((k, elemento) {
      if (elemento.isNotEmpty) {
        widgetsOggi.add(ExpansionTile(
            leading: getIcon(k),
            title: Text(k),
            children: widgetOggiDynamic(k, elemento, context, refresh: aggiornaOggi)));
      }
    });
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

  getIcon(type) {
    if (type == 'Voti') {
      return Icon(FontAwesomeIcons.pen, size: 22.0);
    }
    if (type == 'Compiti') {
      return Icon(FontAwesomeIcons.book, size: 22.0);
    }
    if (type == 'Argomenti') {
      return Icon(FontAwesomeIcons.chalkboardTeacher, size: 22.0);
    }
    if (type == 'Note') {
      return Icon(FontAwesomeIcons.frown, size: 22.0);
    }
    if (type == 'Assenze') {
      return Icon(FontAwesomeIcons.userTimes, size: 22.0);
    }
    if (type == 'Bacheca') {
      return Icon(FontAwesomeIcons.fileAlt, size: 22.0);
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
