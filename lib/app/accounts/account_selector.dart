import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AccountSelector extends StatefulWidget {
  const AccountSelector(
      {super.key,
      required this.allowMultiSelection,
      required this.filterSavingAccounts,
      this.selectedAccounts = const []});

  final bool allowMultiSelection;
  final bool filterSavingAccounts;

  final List<Account> selectedAccounts;

  @override
  State<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends State<AccountSelector> {
  List<Account>? allAccounts;

  late List<Account> selectedAccounts;

  @override
  void initState() {
    super.initState();

    selectedAccounts = widget.selectedAccounts;

    AccountService.instance.getAccounts().first.then((acc) {
      setState(() {
        allAccounts = acc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(color: colors.background),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetHeader(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                child: Text(
                  'Select an account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Builder(builder: (context) {
                if (allAccounts != null) {
                  return Column(
                    children: [
                      if (!widget.allowMultiSelection)
                        ...List.generate(allAccounts!.length, (index) {
                          final account = allAccounts![index];

                          return RadioListTile(
                            value: account.id,
                            title: Text(account.name),
                            secondary: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: colors.primary.withOpacity(0.2)),
                              child:
                                  account.icon.display(color: colors.primary),
                            ),
                            groupValue: selectedAccounts.firstOrNull?.id,
                            onChanged: (value) {
                              setState(() {
                                selectedAccounts = [account];

                                Navigator.of(context).pop(selectedAccounts);
                              });
                            },
                          );
                        })
                    ],
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              }),
              const SizedBox(height: 22),
            ],
          ),
          if (widget.allowMultiSelection) BottomSheetFooter(onSaved: () {})
        ]),
      ),
    );
  }
}
