import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnalogicRotator extends StatefulWidget {
  static const String routeName = "/analogicRotator";
  final ValueNotifier<double>
      value; // Valeur écoutée et modifiée par le Rotator
  final int
      sensibility; // Valeur de sensibilité plus elle est faible plus le rotateur tournera vite
  final double max;
  final double min;
  final bool
      circularBahaviour; // Si true alors le dépassement de la valeur max entrainera un retour à la valeur min et inversement
  final CustomPainter painter; // Painter utiliser pour dessiner le bouton
  final double
      rotationAngle; // Angle duquel tourne le bouton à chaque fois en radian
  final Function add;
  final Function sub;

  AnalogicRotator({
    @required this.value,
    this.sensibility = 5,
    this.max = double.infinity,
    this.min = double.negativeInfinity,
    this.circularBahaviour = true,
    this.painter = const SpeedRotatorPainter(),
    this.rotationAngle = 0.1,
    @required this.add,
    @required this.sub,
  });

  @override
  _AnalogicRotatorState createState() => _AnalogicRotatorState();
}

class _AnalogicRotatorState extends State<AnalogicRotator> {
  double _xCenter = 0;
  double _yCenter = 0;
  int counter = 0;
  double _rotatorPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onPanDown: (details) {
          _xCenter = details.localPosition.dx;
          _yCenter = details.localPosition.dy;
        },
        onPanUpdate: _panHandler,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double minSize = min(constraints.maxWidth, constraints.maxHeight);
            return Container(
              width: minSize,
              height: minSize,
              child: Transform.rotate(
                angle: _rotatorPosition,
                child: CustomPaint(
                  painter: widget.painter,
                ),
              ),
            );
          },
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
          setState(() {
            _rotatorPosition += widget.rotationAngle;
          });
          widget.add(widget.value.value);
        } else if (widget.circularBahaviour) {
          widget.value.value = widget.min;
        }
        counter = -widget.sensibility;
      }
    } else {
      counter--;
      if (counter <= -widget.sensibility) {
        if (widget.value.value > widget.min) {
          setState(() {
            _rotatorPosition -= widget.rotationAngle;
          });
          widget.sub(widget.value.value);
        } else if (widget.circularBahaviour) {
          widget.value.value = widget.max;
        }
        counter = widget.sensibility;
      }
    }
    print(widget.value);
  }
}

class SpeedRotatorPainter extends CustomPainter {
  const SpeedRotatorPainter();
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    canvas.drawCircle(
        Offset(minSize / 2, minSize / 2),
        minSize / 2 - 5,
        Paint()
          ..color = Colors.grey[200]
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(minSize / 2, minSize / 2),
        minSize / 2 - 10,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(minSize / 2, minSize / 2),
        minSize / 2 - 15,
        Paint()
          ..color = Colors.grey[300]
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
