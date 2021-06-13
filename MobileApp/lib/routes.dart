import 'package:remotecontrolmsfs/Instruments/displays.dart';
import 'package:remotecontrolmsfs/Instruments/knobs.dart';
import 'package:remotecontrolmsfs/breakdowns.dart';

import 'Instruments/artificialHorizon.dart';
import 'Instruments/gauge.dart';
import 'Instruments/radioPanel.dart';
import 'webSocket.dart';

class Routes {
  static const String webSocket = ConnectionWidget.routeName;
  static const String gauge = Anemometre.routeName;
  static const String aritficialHorizon = Horizon3D.routeName;
  static const String anologicRotator = AnalogicRotator.routeName;
  static const String cockpit = '/cockpit';
  static const String breakdowns = BreakdownManager.routeName;
  static const String display = SegmentDisplay.routeName;
  static const String radioPanel = RadioPanel.routeName;
}
