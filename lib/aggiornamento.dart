import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

final updatedPubspec =
    'https://raw.githubusercontent.com/peppelg/argo_scuolanext_famiglia_unofficial_app/master/pubspec.yaml';
var checkedDialog = false;

class AggiornamentoRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AggiornamentoRouteState();
  }
}

class _AggiornamentoRouteState extends State<AggiornamentoRoute> {
  String appVersion = '...';
  String latestAppVersion = '...';
  var updateButton = 0;
  @override
  Widget build(BuildContext context) {
    var updateWidgets = <Widget>[
      Text('Versione corrente: ' + appVersion, textScaleFactor: 2),
      Text('Ultima versione: ' + latestAppVersion, textScaleFactor: 2),
    ];
    if (updateButton == 1) {
      updateWidgets
          .add(Text('\nNuova versione disponibile.', textScaleFactor: 2));
      updateWidgets.add(Padding(
          padding: EdgeInsets.only(top: 30),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    launch('https://peppelg.space/argo_famiglia');
                  },
                  child: Text(
                    'Scarica nuova versione',
                  )))));
    } else if (updateButton == 2) {
      updateWidgets.add(Text('\nL\'app è aggiornata :)', textScaleFactor: 2));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Verifica aggiornamenti app'),
        ),
        body: ListView(
            padding: const EdgeInsets.all(40.0), children: updateWidgets));
  }

  void checkUpd() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version + '+' + packageInfo.buildNumber;
    });
    var newVersion = 0;
    var check = await checkUpdates();
    if (check.containsKey('error')) {
      Fluttertoast.showToast(msg: 'Errore:\n\n' + check['error']);
      return;
    }
    if (check['update_available'] == true) {
      newVersion = 1;
    } else {
      newVersion = 2;
    }
    setState(() {
      latestAppVersion = check['latest_version'];
      updateButton = newVersion;
    });
  }

  void initState() {
    super.initState();
    checkUpd();
  }
}

Future checkUpdates() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var appVersion = packageInfo.version + '+' + packageInfo.buildNumber;
    Response response = await Dio().get(updatedPubspec);
    var pubspec = loadYaml(response.data.toString());
    var update;
    if (pubspec['version'] != appVersion) {
      update = true;
    } else {
      update = false;
    }
    return {'update_available': update, 'latest_version': pubspec['version']};
  } catch (e) {
    return {'update_available': false, 'error': e.toString()};
  }
}

Future checkUpdatesDialog(context) async {
  if (checkedDialog == true) {
    return;
  }
  var check = await checkUpdates();
  checkedDialog = true;
  if (check['update_available'] == true) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aggiornamento disponibile'),
          content: Text(
              'È disponibile un nuovo aggiornamento dell\'app.\nNuova versione: ' +
                  check['latest_version'] +
                  '\n\nDesideri aggiornare?'),
          actions: <Widget>[
            FlatButton(
              child: new Text('AGGIORNA'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/aggiornamento');
              },
            ),
          ],
        );
      },
    );
  }
}
