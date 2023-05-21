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
    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 2, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: onDetailsClick,
                  iconSize: 16,
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
