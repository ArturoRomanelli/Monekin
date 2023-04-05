import 'package:flutter/material.dart';

class BottomSheetFooter extends StatefulWidget {
  const BottomSheetFooter({super.key, required this.onSaved});

  final void Function() onSaved;

  @override
  State<BottomSheetFooter> createState() => _BottomSheetFooterState();
}

class _BottomSheetFooterState extends State<BottomSheetFooter> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const Divider(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: IconButton.styleFrom(
                        side: BorderSide(color: colors.outline),
                        backgroundColor: colors.background)
                    .copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return colors.onSurface;
                    }
                    return null;
                  }),
                ),
              ),
              FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () => {
                        widget.onSaved(),
                      }),
            ],
          ),
        ),
      ],
    );
  }
}
