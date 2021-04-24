import 'dart:math';

import 'package:flutter/material.dart';

class SegmentDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // 1
          Positioned(
            top: 50,
            left: 50,
            child: SizedBox(
              width: 50,
              height: 90,
              child: Transform.rotate(
                angle: 90 * pi / 180,
                child: CustomPaint(
                  painter: SegmentPainter(),
                ),
              ),
            ),
          ),
          // 2
          // Positioned(
          //   child: CustomPaint(
          //     painter: SegmentPainter(),
          //   ),
          // ),
          // // 3
          // Positioned(
          //   child: CustomPaint(
          //     painter: SegmentPainter(),
          //   ),
          // ),
          // // 4
          // Positioned(
          //   child: Transform.rotate(
          //     angle: 90 * pi / 180,
          //     child: CustomPaint(
          //       painter: SegmentPainter(),
          //     ),
          //   ),
          // ),
          // // 5
          // Positioned(
          //   child: CustomPaint(
          //     painter: SegmentPainter(),
          //   ),
          // ),
          // // 6
          // Positioned(
          //   child: CustomPaint(
          //     painter: SegmentPainter(),
          //   ),
          // ),
          // // 7
          // Positioned(
          //   child: Transform.rotate(
          //     angle: 90 * pi / 180,
          //     child: CustomPaint(
          //       painter: SegmentPainter(),
          //     ),
          //   ),
          // ),
        ],
      );
    });
  }
}

class SegmentPainter extends CustomPainter {
  final bool isOn;
  SegmentPainter({
    this.isOn = true,
  });
  @override
  void paint(Canvas canvas, Size size) {
    print(size);
    Paint paint = Paint()..style = PaintingStyle.fill;
    if (isOn) {
      paint..color = Colors.yellow;
    } else {
      paint..color = Colors.grey;
    }
    Path path = Path()
      ..moveTo(0, 0)
      ..relativeLineTo(size.width / 2, size.height / 4)
      ..relativeLineTo(0, size.height / 2)
      ..relativeLineTo(-size.width / 2, size.height / 4)
      ..relativeLineTo(-size.width / 2, -size.height / 4)
      ..relativeLineTo(0, -size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
