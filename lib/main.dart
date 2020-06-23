import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
// import 'dart:io';

import 'package:uni_links/uni_links.dart';
// import 'package:flutter/services.dart' show PlatformException;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'external login / signin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription _sub;
  String _paramsCatched;

  @override
  void initState() {
    initUniLinksStream();
    initUniLinks();
    super.initState();
  }

  _launchURL() async {
    const url = 'https://external-login-test-8d9a9.web.app/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _decodeParams(Uri uri) {
    String queryParams = uri.queryParameters['code'];
    if (queryParams != null) {
      setState(() {
        _paramsCatched = queryParams;
      });
    }
  }

  Future<Null> initUniLinksStream() async {
    _sub = getUriLinksStream().listen((Uri uri) {
      _decodeParams(uri);
    }, onError: (err) {});
  }

  Future<Null> initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      print('initial link: $initialLink');
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _paramsCatched != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('received:'),
                  FittedBox(
                    child: Text(
                      _paramsCatched,
                      style: TextStyle(
                        fontSize: 27,
                      ),
                    ),
                  ),
                  Container(height: 30),
                  RaisedButton(
                    onPressed: () => setState(() {
                      _paramsCatched = null;
                    }),
                    child: Text('reset'),
                  ),
                ],
              )
            : RaisedButton(
                onPressed: _launchURL,
                child: Text('login/signin'),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
