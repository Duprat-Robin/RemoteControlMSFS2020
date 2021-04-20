import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ArtificialHorizon extends StatefulWidget {
  static const String routeName = '/artificial';
  final ValueListenable<double> roll;
  final ValueListenable<double> pitch;
  ArtificialHorizon(this.roll, this.pitch);

  @override
  _ArtificialHorizonState createState() => _ArtificialHorizonState();
}

class _ArtificialHorizonState extends State<ArtificialHorizon> {
  @override
  Widget build(BuildContext context) {
    widget.roll.addListener(setAngle);
    widget.pitch.addListener(setAngle);
    return Expanded(
      child: Container(
        child: Stack(
          children: [
            Positioned(
              top: 200 * widget.pitch.value,
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
  final ValueListenable<double> roll; // Angle en deg
  final ValueListenable<double> pitch; // Angle en deg
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
          20
        ]);

  @override
  _HorizonPaintedState createState() => _HorizonPaintedState();
}

class _HorizonPaintedState extends State<HorizonPainted> {
  double _pitch;
  Map<double, rollGraduationType> _rollGraduations =
      {}; // graduations positives en radian sans le pi/2

  @override
  void initState() {
    super.initState();
    widget.rollGraduations.forEach((key, value) {
      _rollGraduations.addAll(
          {key * pi / 180 - pi / 2: value, -key * pi / 180 - pi / 2: value});
    });
    widget.roll.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: HorizonPainter(
              widget.roll.value,
              _rollGraduations,
            ),
          ),
        );
      },
    );
  }
}

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
    // Rectangle de fond
    Rect mainRect = new Rect.fromLTWH(0, 0, minSize, minSize);
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
      ..arcToPoint(
          Offset(minSize / 2 + constructionRect.height / 2 * cos(roll),
              minSize / 2 + constructionRect.height / 2 * sin(roll)),
          radius: Radius.circular(constructionRect.height / 2));
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
