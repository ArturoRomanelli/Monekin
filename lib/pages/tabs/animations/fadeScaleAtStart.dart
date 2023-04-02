import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeScaleAtStart extends StatefulWidget {
  const FadeScaleAtStart({super.key, required this.child});

  final Widget child;

  @override
  State<FadeScaleAtStart> createState() => _FadeScaleAtStartState();
}

class _FadeScaleAtStartState extends State<FadeScaleAtStart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  void _animationListener() {
    setState(() {});
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _animationController.addListener(_animationListener);
    _animationController.forward(from: 0.0);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.removeListener(_animationListener);
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeScaleTransition(
      animation:
          Tween<double>(begin: 0.0, end: 1.0).animate(_animationController),
      child: widget.child,
    );
  }
}
