import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IconSelectorModal extends StatefulWidget {
  const IconSelectorModal(
      {super.key, required this.preselectedIconID, this.onIconSelected});

  final String preselectedIconID;

  final void Function(SupportedIcon selectedIcon)? onIconSelected;

  @override
  State<IconSelectorModal> createState() => _IconSelectorModalState();
}

class _IconSelectorModalState extends State<IconSelectorModal> {
  SupportedIcon? _selectedIcon;

  @override
  void initState() {
    super.initState();

    _selectedIcon =
        SupportedIconService.instance.getIconByID(widget.preselectedIconID);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.85,
        minChildSize: 0.625,
        initialChildSize: 0.85,
        builder: (context, scrollController) {
          final iconsByScope = SupportedIconService.instance.getIconsByScope();

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Scaffold(
              body: Column(children: [
                const BottomSheetHeader(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select an icon',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text(
                            'Identify your account',
                          ),
                        ],
                      ),
                      Chip(
                        side: BorderSide(color: colors.primary, width: 2),
                        //  backgroundColor: Theme.of(context).primaryColorLight,
                        label: _selectedIcon!.display(size: 34),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.vertical,
                        child: Column(
                            children: iconsByScope.keys.toList().map((scope) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  const Divider(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 16),
                                    color: colors.background,
                                    child:
                                        Text(toBeginningOfSentenceCase(scope)!),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Wrap(
                                  spacing: 8, // gap between adjacent cards
                                  runSpacing: 12, // gap between lines
                                  children: iconsByScope[scope]!
                                      .map((e) => Card(
                                            elevation: 1,
                                            clipBehavior: Clip.antiAlias,
                                            color: _selectedIcon?.id == e.id
                                                ? colors.primary
                                                : null,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedIcon = e;
                                                });
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: e.display(
                                                      size: 34,
                                                      color:
                                                          _selectedIcon?.id ==
                                                                  e.id
                                                              ? colors.onPrimary
                                                              : null)),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(
                                // Margin between the icon groups
                                height: 10,
                              )
                            ],
                          );
                        }).toList()),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.background.withOpacity(0),
                              colors.background
                            ],
                          )),
                        ),
                      )
                    ],
                  ),
                ),
                BottomSheetFooter(
                    onSaved: () => {
                          widget.onIconSelected!(_selectedIcon!),
                          Navigator.pop(context)
                        })
              ]),
            ),
          );
        });
  }
}
