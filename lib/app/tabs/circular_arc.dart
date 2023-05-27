import 'dart:math';

import 'package:finlytics/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CircularArc extends StatefulWidget {
  const CircularArc(
      {super.key,
      required this.value,
      required this.width,
      required this.color})
      : assert(value < 1 && value >= 0);

  /// Percentage of the arch to occupy. Must be a value between 0 and 1
  final double value;

  final double width;

  final Color color;

  @override
  State<CircularArc> createState() => _CircularArcState();
}

class _CircularArcState extends State<CircularArc> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: 0,
        end: pi * widget.value,
      ),
      builder: (context, value, child) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(widget.width, widget.width * 0.4),
              painter: _CircularArcPainter(
                  null, true, widget.width * 0.45, widget.color),
            ),
            CustomPaint(
              size: Size(widget.width, widget.width * 0.4),
              painter: _CircularArcPainter(
                  value, false, widget.width * 0.45, widget.color),
            ),
            Positioned.fill(
              top: widget.width * 0.1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                    NumberFormat.decimalPattern()
                        .format((widget.value * 100).floor()),
                    style: TextStyle(
                        fontSize: 32,
                        color: widget.color.darken(),
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircularArcPainter extends CustomPainter {
  double? arc;
  bool isBackground;

  Color color;

  double radius;

  _CircularArcPainter(this.arc, this.isBackground, this.radius, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromCircle(center: size.bottomCenter(Offset.zero), radius: radius);

    const startAngle = -pi;

    final sweepAngle = arc != null ? arc! : pi;

    const useCenter = false;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = isBackground ? color.withOpacity(0.2) : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
