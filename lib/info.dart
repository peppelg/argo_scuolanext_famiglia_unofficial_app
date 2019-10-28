import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'backdropWidgets.dart';

class InfoRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
        title: Text('Informazioni'),
        backLayer: getBackdrop(context),
        frontLayer: Markdown(
            data:
                "App open-source non ufficiale per Argo ScuolaNext.\n\n[Sito dell'app](https://peppelg.space/argo_famiglia)\n[Canale Telegram degli aggiornamenti](https://t.me/scuolanext)\n[Codice sorgente](https://github.com/peppelg/argo_scuolanext_famiglia_unofficial_app)\n\nSe l'app non funziona, vai sul sito e controlla se c'è una nuova versione. Se il problema persiste apri un'issue su GitHub.\n\n---\n*Icona creata da Prosymbols per www.flaticon.com*",
            onTapLink: (href) {
              launch(href);
            }));
  }
}
