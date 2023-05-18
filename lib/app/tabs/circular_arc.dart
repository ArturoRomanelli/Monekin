import 'dart:math';

import 'package:flutter/material.dart';

class CircularArc extends StatefulWidget {
  const CircularArc({super.key, required this.value, required this.size})
      : assert(value < 1 && value > 0);

  /// Percentage of the arch to occupy. Must be a value between 0 and 1
  final double value;

  final double size;

  @override
  State<CircularArc> createState() => _CircularArcState();
}

class _CircularArcState extends State<CircularArc>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    final curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    animation =
        Tween<double>(begin: 0, end: pi * widget.value).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: ProgressArc(null, true),
        ),
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: ProgressArc(animation.value, false),
        )
      ],
    );
  }
}

class ProgressArc extends CustomPainter {
  double? arc;
  bool isBackground;

  ProgressArc(this.arc, this.isBackground);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
        center: size.bottomLeft(Offset.zero), radius: size.width);

    const startAngle = -pi;

    final sweepAngle = arc != null ? arc! : pi;

    const useCenter = false;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = isBackground ? Colors.red.withOpacity(0.2) : Colors.red
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
