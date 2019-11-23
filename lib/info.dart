import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Informazioni'),
        ),
        body: Markdown(
            data:
                "App open-source non ufficiale per Argo ScuolaNext.\n\n[Sito dell'app](https://peppelg.space/argo-famiglia)\n[Canale Telegram degli aggiornamenti](https://t.me/scuolanext)\n[Codice sorgente](https://github.com/peppelg/argo_scuolanext_famiglia_unofficial_app)\n[Debug API](https://app.debug)\n\nSe l'app ha qualche problema, controlla se c'è una nuova versione. Se il problema persiste apri un'issue su GitHub.\n\n---\n\tIcona creata da Prosymbols per www.flaticon.com\n\tIcone \"homework\", \"timetable\", \"calendar\" create da Freepik per www.flaticon.com.",
            onTapLink: (href) {
              if (href == 'https://app.debug') {
                Navigator.of(context).pushNamed('/debugApi');
              } else {
                launch(href);
              }
            }));
  }
}
