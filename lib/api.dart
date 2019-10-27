import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

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
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  Hive.init(appDocPath);
  var box = await Hive.openBox('argo_famiglia');
  box.put('auth_token', auth_token);
  box.put('cod_min', cod_min);
  box.put('prg_scheda', prg_scheda);
  box.put('prg_alunno', prg_alunno);
  box.put('prg_scuola', prg_scuola);
}

Future loadToken() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  Hive.init(appDocPath);
  var box = await Hive.openBox('argo_famiglia');
  if (await box.get('auth_token') != null) {
    fullHeaders['x-auth-token'] = await box.get('auth_token');
    fullHeaders['x-cod-min'] = await box.get('cod_min');
    fullHeaders['x-prg-scheda'] = await box.get('prg_scheda');
    fullHeaders['x-prg-alunno'] = await box.get('prg_alunno');
    fullHeaders['x-prg-scuola'] = await box.get('prg_scuola');
    return 'OK';
  } else {
    return 'login';
  }
}

formatDate(date) {
  return DateFormat('dd/M/y').format(DateTime.parse(date)).toString();
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
        saveToken(
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
    materieVoti[voto['desMateria']]['voti'].add([
      voto['decValore'],
      formatDate(voto['datGiorno']),
      voto['codVotoPratico'],
      voto['desCommento'],
      voto['desProva']
    ]);
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
      'assenza': formatDate(assenza['datAssenza']) +
          (assenza['flgDaGiustificare'] == true ? '' : ' (da giustificare)'),
      'prof': assenza['registrataDa']
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
