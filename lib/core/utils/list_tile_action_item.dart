import 'package:flutter/material.dart';

class ListTileActionItem {
  final String label;
  final IconData icon;

  final void Function() onClick;

  ListTileActionItem({
    required this.label,
    required this.icon,
    required this.onClick,
  });
}
