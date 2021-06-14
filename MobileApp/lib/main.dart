import 'package:flutter/material.dart';
import 'package:remotecontrolmsfs/Instruments/artificialHorizon.dart';
import 'package:remotecontrolmsfs/Instruments/displays.dart';
import 'package:remotecontrolmsfs/Instruments/knobs.dart';
import 'package:remotecontrolmsfs/breakdowns.dart';
import 'package:remotecontrolmsfs/sim.dart';
import 'Instruments/gauge.dart';
import 'Instruments/instrument.dart';
import 'Instruments/radioPanel.dart';
import 'webSocket.dart';
import 'routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final title = 'FlightSimConnector Demo';
  static final Sim mainSim = Sim();
  static final ConnectionWidget webSocket = ConnectionWidget(
    title: title,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: Routes.cockpit, routes: {
      Routes.webSocket: (context) => webSocket,
      Routes.gauge: (context) => Anemometre(mainSim.speed),
      Routes.breakdowns: (context) => BreakdownManager(),
      Routes.anologicRotator: (context) =>
          AnalogicRotator(value: valFreqRadio, add: incrfreq, sub: decrfreq),
      Routes.cockpit: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Cockpit'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.construction),
                  tooltip: 'Open breakdown manager',
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.breakdowns);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_input_antenna),
                  tooltip: 'Open radio panel',
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.radioPanel);
                  },
                ),
              ],
            ),
            body: Row(
              children: [
                InstrumentLayout(
                    tag: 'horiz',
                    child:
                        HorizonPainted.standard(mainSim.roll, mainSim.pitch)),
                InstrumentLayout(
                    tag: 'anemo',
                    child:
                        AnemometrePainted(mainSim.speed, 200, 150, 85, 70, 55)),
              ],
            ),
          ),
      Routes.display: (context) => SegmentDisplay(),
      Routes.aritficialHorizon: (context) => InstrumentLayout(
            tag: 'horiz3D',
            child: Horizon3D(
              roll: mainSim.roll,
              pitch: mainSim.pitch,
            ),
          ),
      Routes.radioPanel: (context) => Row(
            children: [
              Flexible(child: RadioPanel()),
            ],
          ),
    });
  }
}
