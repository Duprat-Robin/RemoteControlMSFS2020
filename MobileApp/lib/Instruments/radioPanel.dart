import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:remotecontrolmsfs/Instruments/displays.dart';
import 'package:remotecontrolmsfs/Instruments/knobs.dart';
import '../main.dart';
import '../webSocket.dart';

//TODO les déplacer dans sim.dart ou au moins identifier la source VHF associée
const double maxFreq = 137.000;
const double minFreq = 108.000;
ValueNotifier<double> valFreqRadio = ValueNotifier<double>(108.975);
ValueNotifier<double> valFreqRadioSTBY = ValueNotifier<double>(112.200);

void incrfreq(double val) {
  valFreqRadioSTBY.value += 0.025;
  MyApp.webSocket
      .sendMessage(DATUM.COM_RADIO_WHOLE_INC.index.toString() + ':1');
}

void decrfreq(double val) {
  valFreqRadioSTBY.value -= 0.025;
  MyApp.webSocket
      .sendMessage(DATUM.COM_RADIO_WHOLE_DEC.index.toString() + ':1');
}

class RadioPanel extends StatelessWidget {
  static const String routeName = "/radioPanel";
  const RadioPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Radio Panel')),
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Flexible(
                child: FrequencyDisplay(
                  freq: valFreqRadio,
                ),
              ),
              Flexible(
                child: SwitchButton(
                  onPressed: _switchFrequencies,
                ),
              ),
              Flexible(
                child: FrequencyDisplay(
                  freq: valFreqRadioSTBY,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Spacer(
                flex: 5,
              ),
              Flexible(
                child: AnalogicRotator(
                  value: valFreqRadioSTBY,
                  add: incrfreq,
                  sub: decrfreq,
                  max: maxFreq,
                  min: minFreq,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _switchFrequencies() {
    double d = valFreqRadio.value;
    valFreqRadio.value = valFreqRadioSTBY.value;
    valFreqRadioSTBY.value = d;
  }
}

class FrequencyDisplay extends StatefulWidget {
  final ValueNotifier<double> freq;
  FrequencyDisplay({Key key, @required this.freq}) : super(key: key);
  @override
  _FrequencyDisplayState createState() => _FrequencyDisplayState();
}

class _FrequencyDisplayState extends State<FrequencyDisplay> {
  int flexFactorSpacer = 1;
  int flexFactor = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
      child: ValueListenableBuilder<double>(
          valueListenable: widget.freq,
          builder: (context, value, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number: value ~/ 100,
                      ),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number: value ~/ 10 - (value ~/ 100) * 10,
                      ),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number: value.truncate() - 10 * (value ~/ 10),
                      ),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: DotDisplay(),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number:
                            (value * 10).truncate() - 10 * (value.truncate()),
                      ),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number: (value * 100).truncate() -
                            10 * (10 * value).truncate(),
                      ),
                    ),
                    Spacer(
                      flex: flexFactorSpacer,
                    ),
                    Flexible(
                      flex: 5,
                      child: SegmentDisplay(
                        number: (value * 1000).truncate() -
                            10 * (value * 100).truncate(),
                      ),
                    ),
                  ])),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SwitchButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SwitchButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black,
        child: TextButton(
          child: Image.asset('assets/images/SwitchButtonIcon.png'),
          onPressed: this.onPressed,
        ),
      ),
    );
  }
}
