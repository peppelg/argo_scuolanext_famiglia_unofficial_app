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

Future argoRequest(headers, request, params) async {
  try {
    params['_dc'] = new DateTime.now().millisecondsSinceEpoch.toString();
    Response response = await Dio().get(endpoint + '/' + request,
        queryParameters: params, options: Options(headers: headers));
    return response.data;
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
        return 'OK';
      } else {
        return 'Errore sconosciuto.';
      }
    }
  }
}

Future votigiornalieri() async {
  var response = await argoRequest(fullHeaders, 'votigiornalieri',
      {'page': '1', 'start': '0', 'limit': '25'});
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

Future note() async {
  var response = await argoRequest(fullHeaders, 'notedisciplinari',
      {'page': '1', 'start': '0', 'limit': '25'});
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

Future assenze() async {
  var response = await argoRequest(
      fullHeaders, 'assenze', {'page': '1', 'start': '0', 'limit': '25'});
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return [];
  }
  var listaAssenze = [];
  for (var assenza in response['dati']) {
    listaAssenze.add({
      'assenza':
          (assenza['desAssenza'] == '' ? '' : assenza['desAssenza'] + ' ') +
              formatDate(assenza['datAssenza']),
      'prof': assenza['registrataDa'],
      'giustificata': assenza.containsKey('giustificataDa')
    });
  }
  return listaAssenze;
}

Future compiti() async {
  var response = await argoRequest(
      fullHeaders, 'compiti', {'page': '1', 'start': '0', 'limit': '25'});
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

Future argomenti() async {
  var response = await argoRequest(
      fullHeaders, 'argomenti', {'page': '1', 'start': '0', 'limit': '25'});
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

Future orario() async {
  var response = await argoRequest(
      fullHeaders, 'orario', {'page': '1', 'start': '0', 'limit': '25'});
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

Future oggi(data) async {
  data = DateFormat('yyyy-MM-dd')
      .format(DateFormat('dd/MM/y').parse(data))
      .toString();
  var response = await argoRequest(fullHeaders, 'oggi',
      {'datGiorno': data, 'page': '1', 'start': '0', 'limit': '25'});
  if (response.containsKey('error')) {
    Fluttertoast.showToast(msg: 'Errore sconosciuto:\n\n' + response['error']);
    return [];
  }
  var listaOggi = [];
  for (var tipo in response['dati']) {
    if (tipo['tipo'] == 'COM') {
      //compito assegnato
      listaOggi.add({
        'tipo': 'compito',
        'titolo': tipo['dati']['desMateria'] + ' ' + tipo['dati']['docente'],
        'descrizione': tipo['dati']['desCompiti']
      });
    }
    if (tipo['tipo'] == 'ARG') {
      //argomento
      listaOggi.add({
        'tipo': 'argomento',
        'titolo': tipo['dati']['desMateria'] + ' ' + tipo['dati']['docente'],
        'descrizione': tipo['dati']['desArgomento']
      });
    }
    if (tipo['tipo'] == 'VOT') {
      //voto
      listaOggi.add({
        'tipo': 'voto',
        'titolo': tipo['dati']['desMateria'] + ' ' + tipo['dati']['docente'],
        'voto': tipo['dati']['decValore'].toString(),
        'descrizione': 'Voto: ' + tipo['dati']['decValore'].toString()
      });
    }
    if (tipo['tipo'] == 'NOT') {
      //nota
      listaOggi.add({
        'tipo': 'nota',
        'titolo': tipo['dati']['docente'],
        'descrizione': tipo['dati']['desNota']
      });
    }
    if (tipo['tipo'] == 'ASS') {
      //assenza
      listaOggi.add({
        'tipo': 'assenza',
        'titolo': tipo['dati']['registrataDa'],
        'descrizione': 'Assenza.'
      });
    }
  }
  return listaOggi;
}
