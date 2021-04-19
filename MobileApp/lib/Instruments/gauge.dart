import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../routes.dart';

// StatefulWidget prennant en paramètre un ValueNotifier de double
// correspondant à un angle en radian indiquant la position de l'aiguille
// La vitesse est kts

class Anemometre extends StatefulWidget {
  final ValueListenable<double> speed;
  static const String routeName = '/gaug';

  Anemometre(this.speed);

  @override
  AnemometreState createState() => AnemometreState();
}

class AnemometreState extends State<Anemometre> {
  double _angle = 0;

  @override
  Widget build(BuildContext context) {
    widget.speed.addListener(convertData);
    return Center(
        child: Container(
            child: Stack(
      children: [
        Image.asset('assets/images/anemo.jpg'),
        Transform.rotate(
          angle: _angle,
          child: Image.asset('assets/images/aiguille.png'),
        ),
      ],
    )));
  }

  // Convertie les données du simu(ici la vitesse) en une variables utilisées
  // pour l'affichage(ici un angle)
  void convertData() {
    setState(() {
      if (widget.speed.value <= 40) {
        _angle = 0;
      } else {
        _angle = 0.314159 + 0.03041592 * (widget.speed.value - 40);
      }
    });
  }
}

class AnemometrePainted extends StatefulWidget {
  final ValueListenable<double> speed;
  final int vne; // never exceed
  final int vno; // normal operating
  final int vfe; // flaps extended
  final int vs0; // decrochage en config décollage
  final int vs1; // decrochage en lisse

  static const String routeName = '/gauge';

  AnemometrePainted(
      this.speed, this.vne, this.vno, this.vfe, this.vs1, this.vs0);

  @override
  _AnemometrePaintedState createState() => _AnemometrePaintedState();
}

class _AnemometrePaintedState extends State<AnemometrePainted> {
  double _angle;
  double _speedToAngle;
  final int _graduationSize = 5; // On veut des graduations de 5 kts

  @override
  void initState() {
    super.initState();
    _speedToAngle = (2 * pi) / (widget.vne + 50);
    widget.speed.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _angle = widget.speed.value * _speedToAngle - pi / 2;
    return Expanded(
      child: Hero(
        tag: "anemo",
        child: Stack(
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: EdgeInsets.all(0.0),
                  margin: EdgeInsets.all(0.0),
                  child: CustomPaint(
                    //size: MediaQuery.of(context).size,
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: AnemometrePainter(
                      speedToAngle(widget.vne),
                      speedToAngle(widget.vno),
                      speedToAngle(widget.vfe),
                      speedToAngle(widget.vs1),
                      speedToAngle(widget.vs0),
                      _graduationSize * _speedToAngle,
                      _angle,
                    ),
                  ),
                );
              },
            ),
            Material(
              child: IconButton(
                icon: Icon(Icons.expand),
                tooltip: 'Expand',
                onPressed: () {
                  if (ModalRoute.of(context)?.settings?.name == '/') {
                    Navigator.pushNamed(context, Routes.paintedGauge);
                  } else {
                    Navigator.pushNamed(context, '/');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double speedToAngle(int speed) {
    return speed * _speedToAngle -
        pi /
            2; // Ou soustrait pi/2 car le drawnArc a son zero au niveau du zéro du cercle trigo
  }
}

class AnemometrePainter extends CustomPainter {
  final double _vne; // never exceed
  final double _vno; // normal operating
  final double _vfe; // flaps extended
  final double _vs0; // decrochage en config décollage
  final double _vs1; // decrochage en lisse
  final double _graduationsSize;
  final double _angle; // angle de l'aiguille
  AnemometrePainter(this._vne, this._vno, this._vfe, this._vs1, this._vs0,
      this._graduationsSize, this._angle);
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    // Différence de taille entre les 2 rectangles
    double _rectanglesSizeOffset = 70;
    // Rectangle de fond
    Rect _mainRect = new Rect.fromLTWH(0, 0, minSize, minSize);
    // Rectangle dans lequel sont circonscrit les cercles / arcs de cercle
    Rect _constructionRect = new Rect.fromLTWH(
        _rectanglesSizeOffset / 2,
        _rectanglesSizeOffset / 2,
        minSize - _rectanglesSizeOffset,
        minSize - _rectanglesSizeOffset);
    // Fond gris
    canvas.drawRect(_mainRect, Paint()..color = Colors.grey);
    Paint _paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;
    canvas.drawArc(_constructionRect, _vs0, _vfe - _vs0, false, _paint);
    _paint.color = Colors.yellow;
    _paint.strokeWidth = 15;
    canvas.drawArc(_constructionRect, _vno, _vne - _vno, false, _paint);
    _paint.color = Colors.green;
    canvas.drawArc(_constructionRect, _vs1, _vno - _vs1, false, _paint);
    _paint.color = Colors.white;
    double _pos = -pi / 2;
    int _i = 0;
    // Dessins des graduations
    while (_pos < _vne) {
      if (_i % 2 == 0) {
        _paint.strokeWidth = 50;
        canvas.drawArc(_constructionRect, _pos, 0.025, false, _paint);
      } else {
        _paint.strokeWidth = 30;
        canvas.drawArc(_constructionRect, _pos, 0.02, false, _paint);
      }
      if (_i % 4 == 0) {
        TextSpan span = new TextSpan(
          style:
              new TextStyle(color: Colors.white, fontSize: minSize / 15), //40
          text: '${_i * 5}',
        );
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            // Les formules ne sont pas jolies et il y a des constantes en dur c'est mal
            new Offset(
                minSize / 2 +
                    (minSize / 2 - 60 - _rectanglesSizeOffset / 2) * cos(_pos) -
                    tp.width / 2,
                minSize / 2 +
                    (minSize / 2 - 60 - _rectanglesSizeOffset / 2) * sin(_pos) -
                    tp.height / 2));
      }

      _pos += _graduationsSize;
      _i++;
    }
    _paint.color = Colors.red;
    _paint.strokeWidth = 50;
    canvas.drawArc(_constructionRect, _vne, 0.03, false, _paint);

    // Dessin de l'aiguille
    _paint.style = PaintingStyle.fill;
    _paint.color = Colors.white;
    double _da = 0.05;
    double _dxy = 20;
    final Path aiguillePath = Path()
      ..moveTo(
          minSize / 2 + (minSize / 2 - _rectanglesSizeOffset / 2) * cos(_angle),
          minSize / 2 + (minSize / 2 - _rectanglesSizeOffset / 2) * sin(_angle))
      ..lineTo(
          minSize / 2 +
              (minSize / 2 - _rectanglesSizeOffset / 2 - _dxy) *
                  cos(_angle + _da),
          minSize / 2 +
              (minSize / 2 - _rectanglesSizeOffset / 2 - _dxy) *
                  sin(_angle + _da))
      ..lineTo(minSize / 2 + 12 * cos(_angle + pi / 2),
          minSize / 2 + 12 * sin(_angle + pi / 2))
      ..lineTo(minSize / 2 + 12 * cos(_angle - pi / 2),
          minSize / 2 + 12 * sin(_angle - pi / 2))
      ..lineTo(
          minSize / 2 +
              (minSize / 2 - _rectanglesSizeOffset / 2 - _dxy) *
                  cos(_angle - _da),
          minSize / 2 +
              (minSize / 2 - _rectanglesSizeOffset / 2 - _dxy) *
                  sin(_angle - _da))
      ..close();
    canvas.drawPath(aiguillePath, _paint);
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 2;
    _paint.color = Colors.black;
    canvas.drawPath(aiguillePath, _paint);
  }

  @override
  bool shouldRepaint(AnemometrePainter oldDelegate) {
    //return _angle != oldDelegate._angle;
    return false;
  }
}
