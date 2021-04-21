import 'package:remotecontrolmsfs/Instruments/artificialHorizon.dart';
import 'package:remotecontrolmsfs/breakdowns.dart';

import 'Instruments/gauge.dart';
import 'webSocket.dart';

class Routes {
  static const String webSocket = ConnectionWidget.routeName;
  static const String gauge = Anemometre.routeName;
  static const String aritficialHorizon = ArtificialHorizon.routeName;
  static const String cockpit = '/cockpit';
  static const String breakdowns = BreakdownManager.routeName;
}
