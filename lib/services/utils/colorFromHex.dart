import 'package:flutter/material.dart';

extension ColorHex on Color {
  /// Return a color instance from an hex string
  static Color get(String hex) =>
      Color(int.parse("0xff${hex.replaceAll('#', '')}"));
}
