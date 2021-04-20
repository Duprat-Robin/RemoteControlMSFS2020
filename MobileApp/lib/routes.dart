import 'package:remotecontrolmsfs/Instruments/artificialHorizon.dart';

import 'Instruments/gauge.dart';
import 'webSocket.dart';

class Routes {
  static const String webSocket = ConnectionWidget.routeName;
  static const String gauge = Anemometre.routeName;
  static const String aritficialHorizon = ArtificialHorizon.routeName;
  static const String cockpit = '/cockpit';
}
