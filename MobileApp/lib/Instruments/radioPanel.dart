import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:remotecontrolmsfs/Instruments/displays.dart';
import '../main.dart';
import '../webSocket.dart';

ValueNotifier<double> valFreqRadio = ValueNotifier<double>(108.500);

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

class RadioPanel extends StatelessWidget {
  static const String routeName = "/radioPanel";
  const RadioPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: FrequencyDisplay(),
        ),
        Flexible(
          child: FrequencyDisplay(),
        ),
      ],
    );
  }
}

class FrequencyDisplay extends StatefulWidget {
  const FrequencyDisplay({Key key}) : super(key: key);

  @override
  _FrequencyDisplayState createState() => _FrequencyDisplayState();
}

class _FrequencyDisplayState extends State<FrequencyDisplay> {
  int hundreds;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: valFreqRadio,
        builder: (context, value, child) =>
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              //FIXME Faire en sorte que les chiffres soient collés (à gauche ou au centre)
              Flexible(
                child: SegmentDisplay(
                  number: value ~/ 100,
                ),
              ),
              Flexible(
                child: SegmentDisplay(
                  number: value ~/ 10 - (value ~/ 100) * 10,
                ),
              ),
              Flexible(
                child: SegmentDisplay(
                  number: value.truncate() - 10 * (value ~/ 10),
                ),
              ),
              Flexible(
                child: SegmentDisplay(
                  number: (value * 10).truncate() - 10 * (value.truncate()),
                ),
              ),
              Flexible(
                child: SegmentDisplay(
                  number:
                      (value * 100).truncate() - 10 * (10 * value).truncate(),
                ),
              ),
              Flexible(
                child: SegmentDisplay(
                  number:
                      (value * 1000).truncate() - 10 * (value * 100).truncate(),
                ),
              ),
            ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
