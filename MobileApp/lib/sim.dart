// Classe contenant tous les paramètres de la simu sous forme de Value Notifier

import 'package:flutter/material.dart';

class Sim {
  final ValueNotifier<double> speed = new ValueNotifier(0.0);
  final ValueNotifier<double> roll = new ValueNotifier(-30.0);
  final ValueNotifier<double> pitch = new ValueNotifier(0.0);

  void parseData(String message) {
    speed.value = double.parse(message);
  }
}
