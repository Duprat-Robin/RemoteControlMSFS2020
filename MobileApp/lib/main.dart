import 'package:flutter/material.dart';
import 'package:remotecontrolmsfs/Instruments/artificialHorizon.dart';
import 'package:remotecontrolmsfs/breakdowns.dart';
import 'package:remotecontrolmsfs/sim.dart';
import 'Instruments/gauge.dart';
import 'Instruments/instrument.dart';
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
    return MaterialApp(initialRoute: Routes.webSocket, routes: {
      Routes.webSocket: (context) => webSocket,
      Routes.gauge: (context) => Anemometre(mainSim.speed),
      Routes.breakdowns: (context) => BreakdownManager(),
      Routes.cockpit: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Cockpit'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_right_alt_outlined),
                  tooltip: 'Open breakdown manager',
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.breakdowns);
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
    });
  }
}
