import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({Key? key, required this.width, required this.height})
      : super(key: key);

  final double width, height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16)),
        ),
      ],
    );
  }
}
