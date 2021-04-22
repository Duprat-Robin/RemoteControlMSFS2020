import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnalogicRotator extends StatefulWidget {
  static const String routeName = "/analogicRotator";
  final ValueNotifier<double>
      value; // Valeur écoutée et modifiée par le Rotator
  final int sensibility; // Valeur de sensibilité
  final double max;
  final double min;
  final bool circularBahaviour;

  AnalogicRotator(
      {@required this.value,
      this.sensibility = 10,
      this.max = double.infinity,
      this.min = double.negativeInfinity,
      this.circularBahaviour = true});

  @override
  _AnalogicRotatorState createState() => _AnalogicRotatorState();
}

class _AnalogicRotatorState extends State<AnalogicRotator> {
  double _xCenter = 0;
  double _yCenter = 0;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onPanDown: (details) {
          _xCenter = details.localPosition.dx;
          _yCenter = details.localPosition.dy;
        },
        onPanUpdate: _panHandler,
        child: ElevatedButton(
          onPressed: () {},
          child: Text("hello"),
        ),
      ),
    );
  }

  void _panHandler(DragUpdateDetails details) {
    /// Pan location on the wheel
    bool onTop = details.localPosition.dy <= _yCenter;
    bool onLeftSide = details.localPosition.dx <= _xCenter;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Pan movements
    bool panUp = details.delta.dy <= 0.0;
    bool panLeft = details.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    /// Absoulte change on axis
    double yChange = details.delta.dy.abs();
    double xChange = details.delta.dx.abs();

    /// Directional change on wheel
    double verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp)
        ? yChange
        : yChange * -1;

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

    // Total computed change
    double rotationalChange = verticalRotation + horizontalRotation;

    bool movingClockwise = rotationalChange > 0;
    bool movingCounterClockwise = rotationalChange < 0;

    if (movingClockwise) {
      counter++;
      if (counter >= widget.sensibility) {
        if (widget.value.value < widget.max) {
          widget.value.value++;
        } else if (widget.circularBahaviour) {
          widget.value.value = widget.min;
        }
        counter = -widget.sensibility;
      }
    } else {
      counter--;
      if (counter <= -widget.sensibility) {
        if (widget.value.value > widget.min) {
          widget.value.value--;
        } else if (widget.circularBahaviour) {
          widget.value.value = widget.max;
        }
        counter = widget.sensibility;
      }
    }
    print(widget.value);
  }
}
