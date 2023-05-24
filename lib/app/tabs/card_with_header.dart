import 'package:flutter/material.dart';

class CardWithHeader extends StatelessWidget {
  const CardWithHeader(
      {super.key,
      required this.title,
      required this.body,
      this.onDetailsClick});

  final Widget body;

  final String title;

  final void Function()? onDetailsClick;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 16;

    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                16,
                onDetailsClick != null ? 2 : iconSize,
                2,
                onDetailsClick != null ? 2 : iconSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                if (onDetailsClick != null)
                  IconButton(
                    onPressed: onDetailsClick,
                    iconSize: iconSize,
                    color: Theme.of(context).primaryColor,
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  )
              ],
            ),
          ),
          const Divider(),
          body
        ],
      ),
    );
  }
}
