import 'package:flutter/material.dart';

class SegmentDisplay extends StatelessWidget {
  static const Map<int, List<bool>> numToList = {
    0: [true, true, true, false, true, true, false],
    1: [false, false, true, false, false, true, false],
    2: [true, false, true, true, true, false, true],
    3: [true, false, true, true, false, true, true],
    4: [false, true, true, true, false, true, false],
    5: [true, true, false, true, false, true, true],
    6: [true, true, false, true, true, true, true],
    7: [true, false, true, false, false, true, false],
    8: [true, true, true, true, true, true, true],
    9: [true, true, true, true, false, true, true],
  }; // Converti le nombre à afficher en une liste de segment qui doivent être allumés
  static const String routeName = "/seg";
  final int number;
  SegmentDisplay({
    this.number = 1,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned(
            top: 50,
            left: 50,
            child: SizedBox(
              width: 50,
              height: 90,
              child: Transform.rotate(
                angle: 0,
                child: CustomPaint(
                  painter: SegmentsPainter(isOn: numToList[number]),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class SegmentsPainter extends CustomPainter {
  final List<bool> isOn;
  static const double horizontalOffset = 10;
  static const double offset = 40;
  SegmentsPainter({
    this.isOn,
  });
  @override
  void paint(Canvas canvas, Size size) {
    print(isOn);
    Paint paint = Paint()..style = PaintingStyle.fill;
    double sizeHeight = size.height / 14;
    double sizeWidth = size.width / 8;
    if (isOn[1]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path = Path()
      ..moveTo(sizeWidth, sizeHeight + 1 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(0, 2 * sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, -sizeHeight)
      ..relativeLineTo(0, -2 * sizeHeight)
      ..close();
    canvas.drawPath(path, paint);
    if (isOn[4]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path1 = Path()
      ..moveTo(sizeWidth, sizeHeight + 2 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(0, 2 * sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, -sizeHeight)
      ..relativeLineTo(0, -2 * sizeHeight)
      ..close();
    canvas.drawPath(path1, paint);
    if (isOn[2]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path2 = Path()
      ..moveTo(7 * sizeWidth, sizeHeight + 1 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(0, 2 * sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, -sizeHeight)
      ..relativeLineTo(0, -2 * sizeHeight)
      ..close();
    canvas.drawPath(path2, paint);
    if (isOn[5]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path3 = Path()
      ..moveTo(7 * sizeWidth, sizeHeight + 2 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(0, 2 * sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, -sizeHeight)
      ..relativeLineTo(0, -2 * sizeHeight)
      ..close();
    canvas.drawPath(path3, paint);
    if (isOn[0]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path4 = Path()
      ..moveTo(sizeWidth, sizeHeight + 1 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, -sizeHeight)
      ..relativeLineTo(4 * sizeWidth, 0)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-4 * sizeWidth, 0)
      ..close();
    canvas.drawPath(path4, paint);
    if (isOn[3]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path5 = Path()
      ..moveTo(sizeWidth, sizeHeight + 2 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, -sizeHeight)
      ..relativeLineTo(4 * sizeWidth, 0)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-4 * sizeWidth, 0)
      ..close();
    canvas.drawPath(path5, paint);
    if (isOn[6]) {
      paint.color = Colors.yellow;
    } else {
      paint.color = Colors.grey;
    }
    Path path6 = Path()
      ..moveTo(sizeWidth, sizeHeight + 3 * 4 * sizeHeight)
      ..relativeLineTo(sizeWidth, -sizeHeight)
      ..relativeLineTo(4 * sizeWidth, 0)
      ..relativeLineTo(sizeWidth, sizeHeight)
      ..relativeLineTo(-sizeWidth, sizeHeight)
      ..relativeLineTo(-4 * sizeWidth, 0)
      ..close();
    canvas.drawPath(path6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
