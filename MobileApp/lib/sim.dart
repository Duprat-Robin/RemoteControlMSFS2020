// Classe contenant tous les paramètres de la simu sous forme de Value Notifier

import 'package:flutter/material.dart';

class Sim {
  final ValueNotifier<double> speed = new ValueNotifier(100.0);
  final ValueNotifier<double> roll = new ValueNotifier(-0.3);
  final ValueNotifier<double> pitch = new ValueNotifier(0.3);
  final ValueNotifier<int> vs0 = new ValueNotifier(55);

  void parseData(String message) {
    for (String parts in message.split(" ")) {
      if (parts.split(":")[0] == "speed") {
        speed.value = double.parse(parts.split(":")[1]);
      } else if (parts.split(":")[0] == "pitch") {
        pitch.value = double.parse(parts.split(":")[1]);
      } else if (parts.split(":")[0] == "bank") {
        roll.value = double.parse(parts.split(":")[1]);
      } else if (parts.split(":")[0] == "vs0") {
        vs0.value = int.parse(parts.split(":")[1]);
      } else {}
    }
  }
}
