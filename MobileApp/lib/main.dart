import 'package:flutter/material.dart';
import 'package:remotecontrolmsfs/Instruments/artificialHorizon.dart';
import 'package:remotecontrolmsfs/sim.dart';
import 'Instruments/gauge.dart';
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
    return MaterialApp(
      routes: {
        Routes.webSocket: (context) => webSocket,
        Routes.gauge: (context) => Anemometre(mainSim.speed),
        Routes.aritficialHorizon: (context) => Row(
              children: [
                ArtificialHorizon(mainSim.roll, mainSim.pitch),
              ],
            ),
        Routes.paintedGauge: (context) => Row(
              children: [
                AnemometrePainted(mainSim.speed, 200, 150, 85, 70, 55),
              ],
            ),
        Routes.cockpit: (context) => Row(
              children: [
                HorizonPainted.standard(mainSim.roll, mainSim.pitch),
                AnemometrePainted(mainSim.speed, 200, 150, 85, 70, 55),
              ],
            ),
      },
    );
  }
}
