import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';

import 'backdropWidgets.dart';
import 'database.dart';

class DatiAnagraficiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DatiAnagraficiRouteState();
  }
}

class _DatiAnagraficiRouteState extends State<DatiAnagraficiRoute> {
  var dati = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<TextSpan> createLines(List<Map<String, String>> elements) {

    var labelStyle = new TextStyle(color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.5));
    var valueStyle = new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Theme.of(context).textTheme.bodyText2.color);

    return elements.map((e) => [
      new TextSpan(text: e['label'], style: labelStyle),
      new TextSpan(text: e['value'] ?? '', style: valueStyle),
      new TextSpan(text: '\n')
    ]).expand((e) => e).toList();
  }

  @override
  Widget build(BuildContext context) {

    var text = dati == null
      ? <TextSpan>[]
      : createLines([
          {'label': 'Nome: ', 'value': dati['desNome']},
          {'label': 'Cognome: ', 'value': dati['desCognome']},
          {'label': 'Sesso: ', 'value': dati['flgSesso'] == 'M' ? 'Maschio' : 'Femmina'},
          {'label': 'Cittadinanza: ', 'value': dati['desCittadinanza']},
          {'label': 'Codice Fiscale: ', 'value': dati['desCf']},
          {'label': 'Telefono: ', 'value': dati['desTelefono']},
          {'label': 'Cellulare: ', 'value': dati['desCellulare']},
          {'label': 'Data di Nascita: ', 'value': dati['datNascita']}, // List.from(dati['datNascita'].split('-').reversed).join('-')
          {'label': 'Comune di Nascita: ', 'value': dati['desComuneNascita']},
          {'label': 'CAP di Nascita: ', 'value': dati['desCap']},
          {'label': 'Comune di Residenza: ', 'value': dati['desComuneResidenza']},
          {'label': 'CAP di Residenza: ', 'value': dati['desCapResidenza']},
          {'label': 'Comune di Recapito: ', 'value': dati['desComuneRecapito']},
          {'label': 'Indirizzo di Recapito: ', 'value': dati['desIndirizzoRecapito']},
          // {'label': '??: ', 'value': dati['desVia']}
        ]);

    return BackdropScaffold(
        title: Text('Dati Anagrafici'),
        backLayer: getBackdrop(context),
        frontLayer: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: aggiornaDatiAnagrafici,
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
              child: new RichText(
                  text: new TextSpan(
                      style: new TextStyle(
                        height: 1.6
                      ),
                      children: text,
                  ),
              )
            )
        )
    );
  }

  Future aggiornaDatiAnagrafici() async {
    var nuoviDati = await Database.get('dati-anagrafici');
    setState(() {
      dati = nuoviDati;
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
}
