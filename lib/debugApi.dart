import 'package:flutter/material.dart';
import 'api.dart';

class DebugApiRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DebugApiRouteState();
  }
}

class _DebugApiRouteState extends State<DebugApiRoute> {
  final request = TextEditingController();
  final response = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Debug API'),
        ),
        body: ListView(padding: const EdgeInsets.all(40.0), children: <Widget>[
          TextField(
            controller: request,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Richiesta',
            ),
          ),
          FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                doReq(request.text);
              },
              child: Text(
                'Invia',
              )),
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: TextField(
                  maxLines: null,
                  readOnly: true,
                  keyboardType: TextInputType.multiline,
                  controller: response))
        ]));
  }

  Future doReq(request) async {
    var r = await simpleRequest(request);
    setState(() {
      response.text = r;
    });
  }
}
