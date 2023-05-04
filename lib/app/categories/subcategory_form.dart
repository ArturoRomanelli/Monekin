import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:finlytics/core/presentation/widgets/icon_selector_modal.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:flutter/material.dart';

class SubcategoryFormDialog extends StatefulWidget {
  const SubcategoryFormDialog(
      {super.key,
      required this.onSubmit,
      this.name = '',
      required this.icon,
      this.color = Colors.black});

  final String name;
  final SupportedIcon icon;
  final Color color;

  final void Function(String name, SupportedIcon icon) onSubmit;

  @override
  State<SubcategoryFormDialog> createState() => _SubcategoryFormDialogState();
}

class _SubcategoryFormDialogState extends State<SubcategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  late SupportedIcon _icon;
  late Color _color;

  @override
  void initState() {
    super.initState();

    _nameController.value = TextEditingValue(text: widget.name);

    setState(() {
      _icon = widget.icon;
      _color = widget.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(color: colors.background),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetHeader(),
          Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select an icon',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return IconSelectorModal(
                                  preselectedIconID: _icon.id,
                                  onIconSelected: (selectedIcon) {
                                    setState(() {
                                      _icon = selectedIcon;
                                    });
                                  },
                                );
                              });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: _color.withOpacity(0.05),
                                border: Border.all(
                                  width: 1,
                                  color: _color,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: _icon.display(size: 50, color: _color)),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _nameController,
                            maxLength: 20,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              labelText: 'Account name *',
                              hintText: 'Ex.: My account',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                textFieldValidator(value, isRequired: true),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              )),
          BottomSheetFooter(onSaved: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSubmit(_nameController.text, _icon);
              Navigator.pop(context);
            }
          })
        ]),
      ),
    );
  }
}
