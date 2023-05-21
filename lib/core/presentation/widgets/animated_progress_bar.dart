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

  final int animationDuration;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration));

    final curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    animation =
        Tween<double>(begin: 0, end: widget.value).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var barRadius = BorderRadius.only(
      topRight: Radius.circular(widget.radius),
      bottomRight: Radius.circular(widget.radius),
    );

    final barColor = widget.color ?? Theme.of(context).primaryColor;

    return Container(
        height: widget.width,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: barRadius, color: barColor.withOpacity(0.12)),
        child: FractionallySizedBox(
          widthFactor: animation.value,
          heightFactor: 1,
          alignment: FractionalOffset.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: barRadius,
              color: barColor,
            ),
          ),
        ));
  }
}
