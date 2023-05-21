import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrendingValue extends StatelessWidget {
  const TrendingValue(
      {super.key,
      required this.percentage,
      this.decimalDigits = 2,
      this.fontSize = 14});

  final double percentage;
  final int decimalDigits;

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          percentage >= 0 ? Icons.trending_up : Icons.trending_down,
          size: fontSize * (9 / 7),
          color: percentage >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits)
              .format(percentage),
          style: TextStyle(
              fontSize: fontSize,
              color: percentage >= 0 ? Colors.green : Colors.red),
        )
      ],
    );
  }
}
