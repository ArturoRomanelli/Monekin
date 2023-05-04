import 'package:flutter/material.dart';

class BottomSheetFooter extends StatefulWidget {
  const BottomSheetFooter(
      {super.key,
      this.onSaved,
      this.submitText = 'Save',
      this.submitIcon = Icons.save});

  final String submitText;
  final IconData submitIcon;
  final void Function()? onSaved;

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
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor:
                        Colors.grey[200], // Background Color
                    disabledForegroundColor: Colors.grey, //Text Color
                  ),
                  icon: Icon(widget.submitIcon),
                  label: Text(widget.submitText),
                  onPressed: widget.onSaved != null
                      ? () {
                          widget.onSaved!();
                        }
                      : null),
            ],
          ),
        ),
      ],
    );
  }
}
