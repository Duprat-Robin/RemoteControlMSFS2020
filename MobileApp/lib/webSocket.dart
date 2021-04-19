import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'routes.dart';
import 'main.dart';

class ConnectionWidget extends StatefulWidget {
  final String title;
  static const String routeName = '/';

  ConnectionWidget({Key key, @required this.title}) : super(key: key);

  @override
  _ConnectionWidgetState createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _addrController = TextEditingController();
  WebSocketChannel _channel;
  List<Widget> _formList = <Widget>[];
  bool _isConnected = false;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _formList.add(
        Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Adresse'),
                controller: _addrController,
              ),
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'port'),
                controller: _portController,
              ),
              ElevatedButton(onPressed: _connect, child: Text("Connect")),
            ],
          ),
        ),
      );
      _isInitialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _formList,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _channel.sink.add(_controller.text);
      } else {
        _channel.sink.add("Default message");
      }
    });
  }

  void _connect() {
    if (_addrController.text.isNotEmpty) {
      print(
          "Connecting to ws://${_addrController.text}:${_portController.text}");
      _channel = WebSocketChannel.connect(
          Uri.parse("ws://${_addrController.text}:${_portController.text}"));
      _channel.stream.listen(
        (message) {
          onMessageReceived(message);
        },
        onDone: () {
          print("ws channel closed");
          Navigator.pushNamed(context, Routes.webSocket);
          _isConnected = false;
          _isInitialized = false;
        },
        onError: (error) {
          debugPrint('ws error $error');
          Navigator.pushNamed(context, Routes.webSocket);
        },
      );
    }
    if (_channel != null && !_isConnected) {
      print("Connection succesful");
      _isConnected = true;
      Navigator.pushNamed(context, Routes.cockpit);
    }
  }

  void onMessageReceived(String message) {
    print("Message received: $message");
    MyApp.mainSim.parseData(message);
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
