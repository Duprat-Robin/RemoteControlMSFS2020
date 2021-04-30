import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cube/flutter_cube.dart';

@deprecated
class ArtificialHorizon extends StatefulWidget {
  static const String routeName = '/artificial';
  final ValueListenable<double> roll;
  final ValueListenable<double> pitch;
  ArtificialHorizon(this.roll, this.pitch);

  @override
  _ArtificialHorizonState createState() => _ArtificialHorizonState();
}

@deprecated
class _ArtificialHorizonState extends State<ArtificialHorizon> {
  @override
  void initState() {
    super.initState();
    widget.roll.addListener(setAngle);
    widget.pitch.addListener(setAngle);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Stack(
          children: [
            Positioned(
              top: widget.pitch.value,
              child: Transform.rotate(
                angle: widget.roll.value,
                child: Image.asset('assets/images/background.png'),
              ),
            ),
            Image.asset('assets/images/fixe.png'),
          ],
          clipBehavior: Clip.hardEdge, // Peut-être à remplacer par antialias
        ),
      ),
    );
  }

  void setAngle() {
    setState(() {});
  }
}

enum rollGraduationType { smallArrow, bigArrow, smallLine, bigLine }

class HorizonPainted extends StatefulWidget {
  final ValueListenable<double> roll; // Angle en rad
  final ValueListenable<double> pitch; // Angle en rad
  final Map<int, rollGraduationType>
      rollGraduations; // graduations positives en degrès accompagné du type
  final List<double> pitchGraduations; // graduations positives en degrès

  HorizonPainted(
      this.roll, this.pitch, this.rollGraduations, this.pitchGraduations);
  HorizonPainted.standard(
      ValueListenable<double> roll, ValueListenable<double> pitch)
      : this(roll, pitch, {
          0: rollGraduationType.bigArrow,
          10: rollGraduationType.smallLine,
          20: rollGraduationType.smallLine,
          30: rollGraduationType.bigLine,
          45: rollGraduationType.smallArrow,
          60: rollGraduationType.bigLine,
          90: rollGraduationType.bigLine
        }, [
          0,
          5,
          10,
          15,
          20,
          25,
          30
        ]);

  @override
  _HorizonPaintedState createState() => _HorizonPaintedState();
}

class _HorizonPaintedState extends State<HorizonPainted> {
  final Map<double, rollGraduationType> _rollGraduations =
      {}; // graduations positives en radian
  final List<double> _pitchGraduations = []; // Graduations en degrés
  static const double _pitchAngleToTranslation = 300;

  @override
  void initState() {
    super.initState();
    widget.rollGraduations.forEach((key, value) {
      _rollGraduations.addAll(
          {key * pi / 180 - pi / 2: value, -key * pi / 180 - pi / 2: value});
    });
    widget.roll.addListener(rebuild);
    widget.pitchGraduations.forEach((value) {
      _pitchGraduations.addAll({value, -value});
    });
    widget.pitch.addListener(rebuild);
  }

  void rebuild() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.pitch.removeListener(rebuild);
    widget.roll.removeListener(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double minSize = min(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              Container(
                width: minSize,
                height: minSize,
                child: Transform.rotate(
                  angle: widget.roll.value,
                  child: Transform.translate(
                    offset: Offset(
                        0, widget.pitch.value * _pitchAngleToTranslation),
                    child: CustomPaint(
                      painter: HorizonBackgroundPainter(
                        pitchAngleToTranslation: _pitchAngleToTranslation,
                        pitchGraduations: _pitchGraduations,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: minSize,
                height: minSize,
                child: Transform.rotate(
                  angle: widget.roll.value,
                  child: CustomPaint(
                    painter: HorizonGraduationPainter(
                        rollGraduations: this._rollGraduations),
                  ),
                ),
              ),
              Container(
                width: minSize,
                height: minSize,
                child: const CustomPaint(
                  painter: const HorizonImmobilePainter(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HorizonImmobilePainter extends CustomPainter {
  const HorizonImmobilePainter();
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    Paint paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(
        Path()
          ..moveTo(0, minSize / 2)
          ..relativeLineTo(minSize / 4, 0)
          ..relativeLineTo(0, minSize / 15),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(minSize, minSize / 2)
          ..relativeLineTo(-minSize / 4, 0)
          ..relativeLineTo(0, minSize / 15),
        paint);
    double _dx = minSize / 50;
    double _dy = minSize / 25;
    final Path aiguillePath = Path()
      ..moveTo(minSize / 2, 20)
      ..relativeLineTo(_dx, _dy)
      ..relativeLineTo(-2 * _dx, 0)
      ..close();
    canvas.drawPath(aiguillePath, paint..strokeWidth = 3);

    canvas.drawOval(Rect.fromLTWH(minSize / 2, minSize / 2, 10, 10),
        paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HorizonGraduationPainter extends CustomPainter {
  final Map<double, rollGraduationType> rollGraduations;
  const HorizonGraduationPainter({@required this.rollGraduations});
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    double rectanglesSizeOffset = 0;
    double innerCircleRadius = minSize - 50;
    Rect constructionRect = new Rect.fromLTWH(
        rectanglesSizeOffset / 2,
        rectanglesSizeOffset / 2,
        minSize - rectanglesSizeOffset,
        minSize - rectanglesSizeOffset);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 15
      ..color = Colors.white;
    double bigGradAngle = 0.03;
    double smallGradAngle = 0.015;
    this.rollGraduations.forEach((key, value) {
      switch (value) {
        case rollGraduationType.smallArrow:
          paint
            ..style = PaintingStyle.fill
            ..strokeWidth = 1;
          double _da = -0.03;
          double _dxy = -15;
          Path arrowPath = Path()
            ..moveTo(minSize / 2 + innerCircleRadius / 2 * cos(key),
                minSize / 2 + innerCircleRadius / 2 * sin(key))
            ..lineTo(
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * cos(key + _da),
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * sin(key + _da))
            ..lineTo(
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * cos(key - _da),
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * sin(key - _da))
            ..close();
          canvas.drawPath(arrowPath, paint);
          break;
        case rollGraduationType.bigArrow:
          paint
            ..style = PaintingStyle.fill
            ..strokeWidth = 1;
          double _da = 0.05;
          double _dxy = -15;
          Path arrowPath = Path()
            ..moveTo(minSize / 2 + innerCircleRadius / 2 * cos(key),
                minSize / 2 + innerCircleRadius / 2 * sin(key))
            ..lineTo(
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * cos(key + _da),
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * sin(key + _da))
            ..lineTo(
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * cos(key - _da),
                minSize / 2 + (innerCircleRadius / 2 - _dxy) * sin(key - _da))
            ..close();
          canvas.drawPath(arrowPath, paint);
          break;
        case rollGraduationType.smallLine:
          paint
            ..strokeWidth = 50
            ..style = PaintingStyle.stroke;
          canvas.drawArc(constructionRect, key - smallGradAngle / 2,
              smallGradAngle, false, paint);
          break;
        case rollGraduationType.bigLine:
          paint
            ..strokeWidth = 80
            ..style = PaintingStyle.stroke;
          canvas.drawArc(constructionRect, key - bigGradAngle / 2, bigGradAngle,
              false, paint);
          break;
        default:
      }
    });
  }

  @override
  bool shouldRepaint(HorizonGraduationPainter oldDelegate) {
    return false;
  }
}

class HorizonBackgroundPainter extends CustomPainter {
  final double pitchAngleToTranslation;
  final List<double> pitchGraduations;
  const HorizonBackgroundPainter(
      {this.pitchAngleToTranslation, this.pitchGraduations});
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, minSize / 2, minSize * 10, -minSize), paint);
    paint..color = Colors.brown;
    canvas.drawRect(
        Rect.fromLTWH(0, minSize / 2, minSize * 10, minSize), paint);
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    this.pitchGraduations.forEach((value) {
      int vDeg = value.toInt();
      if (value % 10 == 0) {
        value *= pi / 180;
        paint..strokeWidth = 4;
        double length = minSize / 7;
        canvas.drawLine(
            Offset(minSize / 2 - length,
                minSize / 2 - value * pitchAngleToTranslation),
            Offset(minSize / 2 + length,
                minSize / 2 - value * pitchAngleToTranslation),
            paint);
        TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.white, fontSize: minSize / 40),
          text: '$vDeg',
        );
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            new Offset(
                minSize / 2 + length + 10,
                minSize / 2 -
                    value * pitchAngleToTranslation -
                    tp.height /
                        2)); // Le 10 en x pour pas être collé à la barre et le tp.higth pour être ee face
      } else {
        value *= pi / 180;
        paint..strokeWidth = 1.5;
        double length = minSize / 14;
        canvas.drawLine(
            Offset(minSize / 2 - length,
                minSize / 2 - value * pitchAngleToTranslation),
            Offset(minSize / 2 + length,
                minSize / 2 - value * pitchAngleToTranslation),
            paint);
      }
    });
  }

  @override
  bool shouldRepaint(HorizonBackgroundPainter oldDelegate) {
    return false;
  }
}

class Horizon3D extends StatefulWidget {
  static const String routeName = "/horiz3D";
  final ValueListenable<double> roll; // Angle en rad
  final ValueListenable<double> pitch; // Angle en rad
  Horizon3D({@required this.roll, @required this.pitch});
  @override
  _Horizon3DState createState() => _Horizon3DState();
}

class _Horizon3DState extends State<Horizon3D> {
  Scene _scene;
  @override
  void initState() {
    super.initState();
    widget.roll.addListener(update);
    widget.pitch.addListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Cube(
        onSceneCreated: (Scene scene) {
          _scene = scene;
          scene.world.add(Object(
              scale: Vector3(9.0, 9.0, 9.0),
              fileName: 'assets/3D/hrz.obj',
              rotation: Vector3(widget.roll.value * 180 / pi, 95,
                  widget.pitch.value * 180 / pi)));
          scene.update();
        },
      ),
    );
  }

  void update() {
    setState(() {
      _scene.update();
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.roll.removeListener(update);
    widget.pitch.removeListener(update);
  }
}

@deprecated
class HorizonPainter extends CustomPainter {
  final double roll; // Angle de rouli en radians sans le pi/2
  final Map<double, rollGraduationType>
      rollGraduations; // Angle de rouli en radians sans le pi/2
  HorizonPainter(this.roll, this.rollGraduations);
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    // Différence de taille entre les 2 rectangles
    double rectanglesSizeOffset = 70;
    // Rectangle dans lequel sont circonscrit les constructions
    Rect constructionRect = new Rect.fromLTWH(
        rectanglesSizeOffset / 2,
        rectanglesSizeOffset / 2,
        minSize - rectanglesSizeOffset,
        minSize - rectanglesSizeOffset);
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    double innerCircleRadius = (minSize - rectanglesSizeOffset - 80) / 2;

    // Tracés qui bougent

    // Pour les deux tracés suivant l'inversion du point de départ et d'arrivé
    // est due au fait que arcToPoint trace de base dans le sens des aiguilles
    // d'une montre
    // Tracé de la partie bleu de l'horizon
    final Path backgroundPath1 = Path()
      ..moveTo(minSize / 2 - constructionRect.height / 2 * cos(roll),
          minSize / 2 - constructionRect.height / 2 * sin(roll))
      ..relativeLineTo(constructionRect.height * cos(roll),
          constructionRect.height * sin(roll))
      ..relativeLineTo(-constructionRect.height * 100 * cos(roll),
          constructionRect.height / 2 * sin(roll))
      ..close();
    // ..arcToPoint(
    //     Offset(minSize / 2 + constructionRect.height / 2 * cos(roll),
    //         minSize / 2 + constructionRect.height / 2 * sin(roll)),
    //     radius: Radius.circular(constructionRect.height / 2));
    canvas.drawPath(backgroundPath1, paint);
    // Tracé de la partie marron de l'horizon
    paint.color = Colors.brown;
    final Path backgroundPath2 = Path()
      ..moveTo(minSize / 2 + constructionRect.height / 2 * cos(roll),
          minSize / 2 + constructionRect.height / 2 * sin(roll))
      ..arcToPoint(
          Offset(minSize / 2 - constructionRect.height / 2 * cos(roll),
              minSize / 2 - constructionRect.height / 2 * sin(roll)),
          radius: Radius.circular(constructionRect.height / 2));
    canvas.drawPath(backgroundPath2, paint);
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawLine(
        Offset(minSize / 2 + constructionRect.height / 2 * cos(roll),
            minSize / 2 + constructionRect.height / 2 * sin(roll)),
        Offset(minSize / 2 - constructionRect.height / 2 * cos(roll),
            minSize / 2 - constructionRect.height / 2 * sin(roll)),
        paint);

    // Dessins des graduations de roulis
    // paint

    double bigGradAngle = 0.03;
    double smallGradAngle = 0.015;
    this.rollGraduations.forEach((key, value) {
      switch (value) {
        case rollGraduationType.smallArrow:
          paint
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..strokeWidth = 1;
          double _da = 0.03;
          double _dxy = 15;
          Path arrowPath = Path()
            ..moveTo(minSize / 2 + innerCircleRadius * cos(roll + key),
                minSize / 2 + innerCircleRadius * sin(roll + key))
            ..lineTo(
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2 - _dxy) *
                        cos(key + roll + _da),
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2 - _dxy) *
                        sin(key + roll + _da))
            ..lineTo(
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2 - _dxy) *
                        cos(roll + key - _da),
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2 - _dxy) *
                        sin(roll + key - _da))
            ..close();
          canvas.drawPath(arrowPath, paint);
          break;
        case rollGraduationType.bigArrow:
          paint
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..strokeWidth = 1;
          double _da = 0.05;
          Path arrowPath = Path()
            ..moveTo(minSize / 2 + innerCircleRadius * cos(roll + key),
                minSize / 2 + innerCircleRadius * sin(roll + key))
            ..lineTo(
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2) *
                        cos(roll + key + _da),
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2) *
                        sin(roll + key + _da))
            ..lineTo(
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2) *
                        cos(roll + key - _da),
                minSize / 2 +
                    (minSize / 2 - rectanglesSizeOffset / 2) *
                        sin(roll + key - _da))
            ..close();
          canvas.drawPath(arrowPath, paint);
          break;
        case rollGraduationType.smallLine:
          paint
            ..color = Colors.white
            ..strokeWidth = 50
            ..style = PaintingStyle.stroke;
          canvas.drawArc(constructionRect, roll + key - smallGradAngle / 2,
              smallGradAngle, false, paint);
          break;
        case rollGraduationType.bigLine:
          paint
            ..color = Colors.white
            ..strokeWidth = 80
            ..style = PaintingStyle.stroke;
          canvas.drawArc(constructionRect, roll + key - bigGradAngle / 2,
              bigGradAngle, false, paint);
          break;
        default:
      }
    });

    // Tracés fixes
    paint
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    double _dx = 10;
    double _dy = 15;
    final Path aiguillePath = Path()
      ..moveTo(minSize / 2, minSize / 2 - constructionRect.height / 2)
      ..lineTo(
          minSize / 2 + _dx, minSize / 2 - (constructionRect.height / 2 - _dy))
      ..lineTo(
          minSize / 2 - _dx, minSize / 2 - (constructionRect.height / 2 - _dy))
      ..close();
    canvas.drawPath(aiguillePath, paint);
  }

  @override
  bool shouldRepaint(HorizonPainter oldDelegate) {
    return false;
  }
}
