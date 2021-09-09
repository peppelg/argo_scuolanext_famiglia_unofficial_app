import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'database.dart';

var endpoint = 'https://www.portaleargo.it/famiglia/api/rest';
var verifyHeaders = {
  'x-version': '2.1.0',
  'X-Requested-With': 'XMLHttpRequest',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'cross-site',
  'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7'
};
var loginHeaders = {
  'x-version': '2.1.0',
  'x-key-app': 'ax6542sdru3217t4eesd9',
  'x-produttore-software': 'ARGO Software s.r.l. - Ragusa',
  'X-Requested-With': 'XMLHttpRequest',
  'x-app-code': 'APF',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'cross-site',
  'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7',
  'x-pwd': '',
  'x-auth-token': '',
  'x-cod-min': '',
  'x-user-id': ''
};
var fullHeaders = {
  'x-version': '2.1.0',
  'x-max-return-record': '100',
  'x-key-app': 'ax6542sdru3217t4eesd9',
  'x-produttore-software': 'ARGO Software s.r.l. - Ragusa',
  'X-Requested-With': 'XMLHttpRequest',
  'x-app-code': 'APF',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'cross-site',
  'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7',
  'x-prg-scheda': '',
  'x-auth-token': '',
  'x-cod-min': '',
  'x-prg-scuola': '',
  'x-prg-alunno': ''
};

Future saveToken(
    auth_token, cod_min, prg_scheda, prg_alunno, prg_scuola) async {
  await Database.put('auth_token', auth_token);
  await Database.put('cod_min', cod_min);
  await Database.put('prg_scheda', prg_scheda);
  await Database.put('prg_alunno', prg_alunno);
  await Database.put('prg_scuola', prg_scuola);
}

Future loadToken() async {
  if (await Database.get('auth_token') != null) {
    fullHeaders['x-auth-token'] = await Database.get('auth_token');
    fullHeaders['x-cod-min'] = await Database.get('cod_min');
    fullHeaders['x-prg-scheda'] = await Database.get('prg_scheda');
    fullHeaders['x-prg-alunno'] = await Database.get('prg_alunno');
    fullHeaders['x-prg-scuola'] = await Database.get('prg_scuola');
    return 'OK';
  } else {
    return 'login';
  }
}

formatDate(date) {
  var dt = DateFormat('dd/MM/y').format(DateTime.parse(date)).toString();
  return dt;
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

Future argoRequest(headers, request, params, {var postParams}) async {
  try {
    params['_dc'] = new DateTime.now().millisecondsSinceEpoch.toString();
    if (postParams == null) {
      Response response = await Dio().get(endpoint + '/' + request,
          queryParameters: params, options: Options(headers: headers));
      return response.data;
    } else {
      Response response = await Dio().post(endpoint + '/' + request,
          data: postParams, options: Options(headers: headers));
      return response.data;
    }
  } catch (e) {
    return {'error': e.toString()};
  }
}

Future simpleRequest(request) async {
  var response = await argoRequest(
      fullHeaders, request, {'page': '1', 'start': '0', 'limit': '25'});
  if (response.containsKey('error')) {
    return 'Errore: ' + response['error'];
  } else {
    return jsonEncode(response);
  }
}

Future login(school, username, password) async {
  var test = await argoRequest(verifyHeaders, 'verifica', {'_dc': ''});
  if (test.containsKey('success')) {
    loginHeaders['x-pwd'] = password;
    loginHeaders['x-cod-min'] = school;
    loginHeaders['x-user-id'] = username;
    var lR = await argoRequest(loginHeaders, 'login', {'_dc': ''});
    if (lR.containsKey('error')) {
      return lR['error'];
    } else {
      if (lR.containsKey('token')) {
        fullHeaders['x-auth-token'] = lR['token'];
        fullHeaders['x-cod-min'] = school;
        fullHeaders['x-prg-scheda'] = '0';
        fullHeaders['x-prg-alunno'] = '0';
        fullHeaders['x-prg-scuola'] = '0';
        var info = await argoRequest(fullHeaders, 'schede', {'_dc': ''});
        fullHeaders['x-prg-scheda'] = info[0]['prgScheda'].toString();
        fullHeaders['x-prg-scuola'] = info[0]['prgScuola'].toString();
        fullHeaders['x-prg-alunno'] = info[0]['prgAlunno'].toString();
        await saveToken(
            fullHeaders['x-auth-token'],
            fullHeaders['x-cod-min'],
            fullHeaders['x-prg-scheda'],
            fullHeaders['x-prg-alunno'],
            fullHeaders['x-prg-scuola']);
        await Database.put('dati-anagrafici', info[0]['alunno']);
        return 'OK';
      } else {
        return 'Errore sconosciuto.';
      }
    }
  }
}

Future votigiornalieri({var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'votigiornalieri',
        {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var materieVoti = {};
  for (var voto in response['dati']) {
    if (voto.containsKey('decValore') &&
        isNumeric(voto['decValore'].toString())) {
      voto['desMateria'] = voto['desMateria'] + ' ' + voto['docente'];
      if (voto['codVotoPratico'] == 'S') {
        voto['codVotoPratico'] = 'scritto';
      }
      if (voto['codVotoPratico'] == 'N') {
        voto['codVotoPratico'] = 'orale';
      }
      if (voto['codVotoPratico'] == 'P') {
        voto['codVotoPratico'] = 'pratico';
      }
      if (!materieVoti.containsKey(voto['desMateria'])) {
        materieVoti[voto['desMateria']] = {'voti': []};
      }
      materieVoti[voto['desMateria']]['voti'].add({
        'voto': voto['decValore'],
        'data': formatDate(voto['datGiorno']),
        'tipo': voto['codVotoPratico'],
        'commento': voto['desCommento'],
        'descrizione': voto['desProva']
      });
    }
  }
  return materieVoti;
}

Future note({var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'notedisciplinari',
        {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return [];
  }
  var listaNote = [];
  for (var nota in response['dati']) {
    listaNote.add({
      'nota': nota['desNota'],
      'prof': nota['docente'],
      'data': formatDate(nota['datNota'])
    });
  }
  return listaNote;
}

Future assenze({var response}) async {
  if (response == null) {
    response = await argoRequest(
        fullHeaders, 'assenze', {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return [];
  }
  var listaAssenze = [];
  var testoAssenza = '';
  for (var assenza in response['dati']) {
    testoAssenza =
        (assenza['desAssenza'] == '' ? '' : assenza['desAssenza'] + ' ') +
            formatDate(assenza['datAssenza']);
    try {
      if (assenza['codEvento'] == 'I' && assenza.containsKey('oraAssenza')) {
        //ingresso + dopo (ritardo)
        testoAssenza = 'Ritardo ' +
            testoAssenza +
            ' ore ' +
            RegExp(r'([01]?[0-9]|2[0-3]):[0-5][0-9]')
                .firstMatch(assenza['oraAssenza'])
                .group(0);
      }
    } catch (e) {}
    listaAssenze.add({
      'assenza': testoAssenza,
      'prof': 'Registrata da: ' +
          assenza['registrataDa'].replaceAll('(', '').replaceAll(')', '') +
          (assenza.containsKey('giustificataDa')
              ? '\nGiustificata da: ' +
                  assenza['giustificataDa']
                      .replaceAll('(', '')
                      .replaceAll(')', '')
              : ''),
      'giustificata': assenza.containsKey('giustificataDa')
          ? true
          : !assenza['flgDaGiustificare']
    });
  }
  return listaAssenze;
}

Future compiti({var response}) async {
  if (response == null) {
    response = await argoRequest(
        fullHeaders, 'compiti', {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var listaCompiti = {};
  for (var compito in response['dati']) {
    compito['desMateria'] = compito['desMateria'] + ' ' + compito['docente'];
    if (!listaCompiti.containsKey(compito['desMateria'])) {
      listaCompiti[compito['desMateria']] = [];
    }
    listaCompiti[compito['desMateria']].add({
      'data': formatDate(compito['datGiorno']),
      'compito': compito['desCompiti']
    });
  }
  return listaCompiti;
}

Future argomenti({var response}) async {
  if (response == null) {
    response = await argoRequest(
        fullHeaders, 'argomenti', {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var listaArgomenti = {};
  for (var argomento in response['dati']) {
    argomento['desMateria'] =
        argomento['desMateria'] + ' ' + argomento['docente'];
    if (!listaArgomenti.containsKey(argomento['desMateria'])) {
      listaArgomenti[argomento['desMateria']] = [];
    }
    listaArgomenti[argomento['desMateria']].add({
      'data': formatDate(argomento['datGiorno']),
      'argomento': argomento['desArgomento']
    });
  }
  return listaArgomenti;
}

Future orario({var response}) async {
  if (response == null) {
    response = await argoRequest(
        fullHeaders, 'orario', {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var tabellaOrario = {};
  for (var ora in response['dati']) {
    if (!tabellaOrario.containsKey(ora['giorno'])) {
      tabellaOrario[ora['giorno']] = [];
    }
    if (!ora.containsKey('lezioni')) {
      ora['lezioni'] = [
        {'materia': '---', 'docente': '---'}
      ];
    }
    tabellaOrario[ora['giorno']].add({
      'ora': ora['numOra'],
      'materia': ora['lezioni'][0]['materia'],
      'prof': ora['lezioni'][0]['docente']
    });
  }
  return tabellaOrario;
}

Future oggi(data, {var response}) async {
  data = DateFormat('yyyy-MM-dd')
      .format(DateFormat('dd/MM/y').parse(data))
      .toString();
  if (response == null) {
    response = await argoRequest(fullHeaders, 'oggi',
        {'datGiorno': data, 'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return [];
  }
  var listaOggi = {
    'Voti': [],
    'Compiti': [],
    'Argomenti': [],
    'Note': [],
    'Assenze': [],
    'Bacheca': []
  };
  for (var tipo in response['dati']) {
    if (tipo['tipo'] == 'VOT') {
      //voto
      var voti = await votigiornalieri(response: {
        'dati': [tipo['dati']]
      });
      voti.forEach((k, v) {
        for (var voto in v['voti']) {
          listaOggi['Voti'].add({'materia': k, 'elemento': voto});
        }
      });
    }
    if (tipo['tipo'] == 'COM') {
      //compiti assegnati
      var elementi = await compiti(response: {
        'dati': [tipo['dati']]
      });
      elementi.forEach((k, v) {
        for (var elemento in v) {
          listaOggi['Compiti'].add({'materia': k, 'elemento': elemento});
        }
      });
    }
    if (tipo['tipo'] == 'ARG') {
      //argomenti lezione
      var elementi = await argomenti(response: {
        'dati': [tipo['dati']]
      });
      elementi.forEach((k, v) {
        for (var elemento in v) {
          listaOggi['Argomenti'].add({'materia': k, 'elemento': elemento});
        }
      });
    }
    if (tipo['tipo'] == 'NOT') {
      //note
      var elementi = await note(response: {
        'dati': [tipo['dati']]
      });
      for (var elemento in elementi) {
        listaOggi['Note'].add({'elemento': elemento});
      }
    }
    if (tipo['tipo'] == 'ASS') {
      //assenze
      var elementi = await assenze(response: {
        'dati': [tipo['dati']]
      });
      for (var elemento in elementi) {
        listaOggi['Assenze'].add({'elemento': elemento});
      }
    }
    if (tipo['tipo'] == 'BAC') {
      //assenze
      var elementi = await bacheca(response: {
        'dati': [tipo['dati']]
      });
      for (var elemento in elementi) {
        listaOggi['Bacheca'].add({'elemento': elemento});
      }
    }
  }
  return listaOggi;
}

Future bacheca({var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'bachecanuova',
        {'page': '1', 'start': '0', 'limit': '25'});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var listaBacheca = [];
  for (var elemento in response['dati']) {
    listaBacheca.add(bacheca_parse(elemento));
  }
  return listaBacheca;
}

Future periodiscrutinio({var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'periodiclasse',
        {'page': '1', 'start': '0', 'limit': '25'});
  }

  if (!(response is List) && response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }

  return response['dati'];
}

Future votiscruitinio({var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'votiscrutinio',
        {'page': '1', 'start': '0', 'limit': '25'});
  }
  // Si controlla che response non sia una lista, quindi che abbia il metodo .containsKey
  // (la richiesta votiscrutinio non ritorna un oggetto con un campo 'dati', bensì una lista)
  if (!(response is List) && response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  var periodi = await periodiscrutinio();

  Map scrutinio = {};
  for (var periodo in periodi)
    scrutinio[periodo['prgPeriodo']] = {
      'titolo': periodo['desPeriodo'],
      'esito': periodo['esito'],
      'dati': []
    };
  
  for (var elemento in response) {
    int periodo = elemento['prgPeriodo'];
    scrutinio[periodo]['dati'].add(elemento);
  }

  return scrutinio;
}

bacheca_parse(elemento) {
  return {
    'oggetto': elemento['desOggetto'],
    'messaggio': elemento['desMessaggio'],
    'link': elemento['desUrl'],
    'data': formatDate(elemento['datGiorno']),
    'id': elemento['prgMessaggio'],
    'presa_visione': elemento['presaVisione'],
    'presa_adesione': elemento['adesione'],
    'richiedi_presa_visione': elemento['richiediPv'],
    'richiedi_presa_adesione': elemento['richiediAd'],
    'allegati': elemento['allegati']
  };
}

Future confermaPresaVisione(presaVisione, id, {var response}) async {
  if (response == null) {
    response = await argoRequest(fullHeaders, 'presavisionebachecanuova', {},
        postParams: {'presaVisione': presaVisione, 'prgMessaggio': id});
  }
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return {};
  }
  return response;
}

getUrl(prgAllegato, prgMessaggio) {
  return endpoint +
      '/messaggiobachecanuova?id=' +
      fullHeaders['x-cod-min'].toUpperCase().padLeft(10, 'F') +
      'II'.padLeft(5, 'E') +
      prgAllegato.toString().padLeft(5, '0') +
      prgMessaggio.toString().padLeft(10, '0') +
      fullHeaders['x-auth-token'].replaceAll('-', '') +
      fullHeaders['x-key-app'];
}
