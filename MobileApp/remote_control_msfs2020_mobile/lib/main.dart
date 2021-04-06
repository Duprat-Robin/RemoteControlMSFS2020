import 'package:flutter/material.dart';

void main() {
  runApp(RCMSFS2020App());
}

class RCMSFS2020App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Control MSFS2020',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppHomePage(title: 'Remote Control MSFS2020 Home Page'),
    );
  }
}

class AppHomePage extends StatefulWidget {
  AppHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  @override
  Widget build(BuildContext context) {}
}
