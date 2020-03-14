import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'widgets.dart';

class NoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NoteRouteState();
  }
}

class _NoteRouteState extends State<NoteRoute> {
  List listaNote = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var widgetsNote = <Widget>[];
    for (var nota in listaNote) {
      widgetsNote.add(Padding(
          padding: EdgeInsets.only(left: 5, top: 5), child: widgetNota(nota)));
    }
    return BackdropScaffold(
        title: Text('Note'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaNote,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsNote))));
  }

  Future aggiornaNote() async {
    var nuoveNote = await note();
    setState(() {
      listaNote = nuoveNote;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
