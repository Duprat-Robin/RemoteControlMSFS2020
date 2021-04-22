import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'routes.dart';
import 'main.dart';

class BreakdownManager extends StatelessWidget {
  static const String routeName = '/breakdownMan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Breakdown Manager')),
      body: ElevatedButton(
        onPressed: () {
          MyApp.webSocket.sendMessage(
              'engine:0'); // Navigate back to first screen when tapped.
        },
        child: Text('Engine failure'),
      ),
    );
  }
}
