import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import '../webSocket.dart';

ValueNotifier<double> valFreqRadio = ValueNotifier(108.0);

void incrfreq(double val) {
  valFreqRadio.value += 0.025;
  MyApp.webSocket
      .sendMessage(DATUM.COM_RADIO_WHOLE_INC.index.toString() + ':1');
}

void decrfreq(double val) {
  valFreqRadio.value -= 0.025;
  MyApp.webSocket
      .sendMessage(DATUM.COM_RADIO_WHOLE_DEC.index.toString() + ':1');
}
