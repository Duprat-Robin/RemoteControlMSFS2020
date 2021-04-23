import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

void incrfreq(double val) {
  MyApp.webSocket.sendMessage('radiofreq+:' + val.toString());
}

void decrfreq(double val) {
  MyApp.webSocket.sendMessage('radiofreq-:' + val.toString());
}
