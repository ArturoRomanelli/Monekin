import 'package:finlytics/core/utils/list_tile_action_item.dart';
import 'package:flutter/material.dart';

class FinlyticsPopuMenuButton extends StatelessWidget {
  const FinlyticsPopuMenuButton({super.key, required this.actionItems});

  final List<ListTileActionItem> actionItems;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return List.generate(actionItems.length, (index) {
          final actionItem = actionItems[index];

          return PopupMenuItem(
              value: index,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(actionItem.icon),
                minLeadingWidth: 26,
                title: Text(actionItem.label),
              ));
        });
      },
      onSelected: (int value) {
        if (actionItems[value].onClick != null) {
          actionItems[value].onClick!();
        }
      },
    );
  }
}
