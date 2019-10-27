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
            data: "App open-source non ufficiale per Argo ScuolaNext.\n\n[Sito dell'app](https://peppelg.space/argo_famiglia)\n[Codice sorgente](https://github.com/peppelg/argo_scuolanext_famiglia_unofficial_app)\n\nIcona creata da Prosymbols da www.flaticon.com",
            onTapLink: (href) {
              launch(href);
            }));
  }
}
