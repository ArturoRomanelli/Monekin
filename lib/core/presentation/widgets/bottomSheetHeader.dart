import 'package:flutter/material.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            const Spacer(),
            Container(
              height: 4,
              width: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey[200],
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
