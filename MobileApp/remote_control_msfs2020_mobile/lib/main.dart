import 'package:flutter/material.dart';
import 'controls_page.dart';

void main() => runApp(RemoteControlApp());

class RemoteControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Control MSFS2020',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Control for Microsoft Flight Simulator 2020'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
            'Welcome in Remote Control for Microsoft Flight Simulator 2020'),
        child: RadioWidget(),
      ),
    );
  }
}
