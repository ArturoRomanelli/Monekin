import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar(
      {super.key,
      required this.value,
      this.radius = 2,
      this.color,
      this.animationDuration = 750,
      this.width = 8})
      : assert(value <= 1 && value >= 0);

  /// Percentage of the bar to occupy. Must be a value between 0 and 1
  final double value;

  final double radius;

  /// Width of the bar
  final double width;

  /// Color of the progress bar. Will be the primary color of the app if null
  final Color? color;

  /// Animation duration in milliseconds
  final int animationDuration;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> {
  @override
  Widget build(BuildContext context) {
    var barRadius = BorderRadius.only(
      topRight: Radius.circular(widget.radius),
      bottomRight: Radius.circular(widget.radius),
    );

    final barColor = widget.color ?? Theme.of(context).primaryColor;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: widget.animationDuration),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: 0,
        end: widget.value,
      ),
      builder: (context, value, child) {
        return Container(
            height: widget.width,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: barRadius, color: barColor.withOpacity(0.12)),
            child: FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              alignment: FractionalOffset.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: barRadius,
                  color: barColor,
                ),
              ),
            ));
      },
    );
  }
}
