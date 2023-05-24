import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrendingValue extends StatelessWidget {
  const TrendingValue(
      {super.key,
      required this.percentage,
      this.decimalDigits = 2,
      this.fontSize = 14,
      this.fontWeight = FontWeight.normal,
      this.filled = false,
      this.outlined = false});

  final double percentage;
  final int decimalDigits;

  final double fontSize;

  final FontWeight fontWeight;

  final bool filled, outlined;

  Widget paintTrendValue() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          percentage >= 0 ? Icons.trending_up : Icons.trending_down,
          size: fontSize * (9 / 7),
          color: _getColorBasedOnPercentage(),
        ),
        const SizedBox(width: 6),
        Text(
          NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits)
              .format(percentage),
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: _getColorBasedOnPercentage()),
        )
      ],
    );
  }

  Color _getColorBasedOnPercentage() {
    return percentage >= 0 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (filled || outlined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: percentage >= 0
              ? const Color.fromARGB(255, 220, 255, 220)
              : const Color.fromARGB(255, 255, 220, 220),
          borderRadius: BorderRadius.circular(fontSize / 3.5),
          border: outlined
              ? Border.all(color: _getColorBasedOnPercentage(), width: 1)
              : null,
        ),
        child: paintTrendValue(),
      );
    } else {
      return paintTrendValue();
    }
  }
}
