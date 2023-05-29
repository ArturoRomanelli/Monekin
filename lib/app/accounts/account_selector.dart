import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
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

    AccountService.instance
        .getAccounts(
          predicate: (acc, curr) => DatabaseImpl.instance.buildExpr([
            if (widget.filterSavingAccounts)
              acc.type.equalsValue(AccountType.saving).not()
          ]),
        )
        .first
        .then((acc) {
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
                      ...List.generate(allAccounts!.length, (index) {
                        final account = allAccounts![index];

                        if (!widget.allowMultiSelection) {
                          return RadioListTile(
                            value: account.id,
                            title: Text(account.name),
                            secondary: account.icon
                                .displayFilled(color: colors.primary),
                            groupValue: selectedAccounts.firstOrNull?.id,
                            onChanged: (value) {
                              setState(() {
                                selectedAccounts = [account];

                                Navigator.of(context).pop(selectedAccounts);
                              });
                            },
                          );
                        } else {
                          return CheckboxListTile(
                            value: selectedAccounts
                                .map((e) => e.id)
                                .contains(account.id),
                            title: Text(account.name),
                            secondary: account.icon
                                .displayFilled(color: colors.primary),
                            onChanged: (value) {
                              if (value == true) {
                                selectedAccounts.add(account);
                              } else {
                                selectedAccounts.removeWhere(
                                    (element) => element.id == account.id);
                              }

                              setState(() {});
                            },
                          );
                        }
                      }),
                      if (widget.allowMultiSelection)
                        ListView(shrinkWrap: true, children: [
                          const SizedBox(height: 14),
                          BottomSheetFooter(
                              onSaved: selectedAccounts.isNotEmpty
                                  ? () => Navigator.of(context)
                                      .pop(selectedAccounts)
                                  : null)
                        ])
                    ],
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              }),
              const SizedBox(height: 22),
            ],
          ),
        ]),
      ),
    );
  }
}
