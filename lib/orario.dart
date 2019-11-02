import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'backdropWidgets.dart';
import 'api.dart';
import 'database.dart';

class OrarioRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrarioRouteState();
  }
}

class _OrarioRouteState extends State<OrarioRoute> {
  Map tabellaOrario = {};
  final nuovoNomeMateria = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var orarioColumns = [DataColumn(label: Text(''))];
    for (var giorno in tabellaOrario.keys) {
      orarioColumns.add(DataColumn(label: Text(giorno)));
    }
    var orarioRows = <DataRow>[];
    var tborario = {}; //orario ordinato in base all'ora
    tabellaOrario.forEach((k, v) {
      for (var materia in v) {
        if (!tborario.containsKey(materia['ora'])) {
          tborario[materia['ora']] = [materia['ora'].toString()];
        }
        tborario[materia['ora']].add(materia['materia']);
      }
    });
    tborario.forEach((ora, v) {
      var cells = <DataCell>[];
      v.asMap().forEach((k, materia) {
        cells.add(DataCell(Text(materia), onTap: () {
          //preme materia x edit
          if (k != 0) {
            //non deve click l'ora
            var giorno = tabellaOrario.keys.toList()[k -
                1]; //k-1 = numero del coso orizzontale, -1 xk si deve togliere colonna orario
            modificaMateriaDialog(giorno, ora, context);
          }
        }));
      });
      orarioRows.add(DataRow(cells: cells));
    });
    var widgetsOrario = <Widget>[
      SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: orarioColumns, rows: orarioRows)))
    ];
    return BackdropScaffold(
        title: Text('Orario'),
        backLayer: getBackdrop(context),
        iconPosition: BackdropIconPosition.leading,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                resetVoti(context);
              })
        ],
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaOrario,
            child: ListView(
                children: new List.from(<Widget>[])..addAll(widgetsOrario))));
  }

  Future aggiornaOrario() async {
    var nuovoOrario = await Database.get('orario');
    if (nuovoOrario == null) {
      nuovoOrario = await orario();
      await Database.put('orario', nuovoOrario);
    }
    setState(() {
      tabellaOrario = nuovoOrario;
    });
  }

  Future modificaMateriaDialog(giorno, ora, context) async {
    var materia = tabellaOrario[giorno][ora - 1]; //liste partono da 0, ore da 1
    nuovoNomeMateria.text = materia['materia'];
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Modifica materia'),
              content: SingleChildScrollView(
                  child: ListBody(children: <Widget>[
                Text('Giorno: ' +
                    giorno +
                    '\nOra: ' +
                    ora.toString() +
                    '\nProf: ' +
                    materia['prof']),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: nuovoNomeMateria,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome materia',
                      ),
                    ))
              ])),
              actions: <Widget>[
                FlatButton(
                  child: Text('Salva'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    modificaMateria(giorno, ora);
                  },
                ),
                FlatButton(
                  child: Text('Chiudi'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }

  Future modificaMateria(giorno, ora) async {
    setState(() {
      tabellaOrario[giorno][ora - 1]['materia'] = nuovoNomeMateria.text;
    });
    await Database.put('orario', tabellaOrario);
  }

  Future resetVoti(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset orario'),
          content: Text(
              'Sei sicuro di voler scaricare il nuovo orario da Argo? I nomi delle materie modificate verranno persi.'),
          actions: <Widget>[
            FlatButton(
              child: new Text('SÌ'),
              onPressed: () async {
                await Database.put('orario', null);
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _refreshIndicatorKey.currentState.show());
              },
            ),
            FlatButton(
              child: new Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
