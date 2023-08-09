import 'package:flutter/material.dart';

import '../../utils/list_tile_action_item.dart';

class MonekinQuickActionsButton extends StatelessWidget {
  const MonekinQuickActionsButton({super.key, required this.actions});

  final List<ListTileActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: actions
                .map((item) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: item
                              .getColorBasedOnRole(context)
                              .withOpacity(0.15),
                          radius: 24,
                          child: IconButton(
                              onPressed: item.onClick,
                              color: item.getColorBasedOnRole(context),
                              icon: Icon(
                                item.icon,
                                size: 32,
                                //  color: Colors.red,
                              )),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
                        )
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
