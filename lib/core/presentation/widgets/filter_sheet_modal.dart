import 'package:finlytics/app/accounts/account_selector.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransactionFilters {
  List<Account>? accounts;
  List<Category>? categories;

  TransactionFilters({this.accounts, this.categories});
}

class FilterSheetModal extends StatefulWidget {
  const FilterSheetModal({super.key, required this.preselectedFilter});

  final TransactionFilters preselectedFilter;

  @override
  State<FilterSheetModal> createState() => _FilterSheetModalState();
}

class _FilterSheetModalState extends State<FilterSheetModal> {
  late TransactionFilters filtersToReturn;

  @override
  void initState() {
    super.initState();

    filtersToReturn = widget.preselectedFilter;
  }

  Widget selector({
    required String title,
    required String? inputValue,
    required Function onClick,
  }) {
    return TextField(
        controller:
            TextEditingController(text: inputValue ?? 'Sin especificar'),
        readOnly: true,
        onTap: () => onClick(),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ));
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
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: AccountService.instance.getAccounts(),
                            builder: (context, snapshot) {
                              return selector(
                                  title: 'Accounts',
                                  inputValue:
                                      filtersToReturn.accounts == null ||
                                              (snapshot.hasData &&
                                                  filtersToReturn
                                                          .accounts!.length ==
                                                      snapshot.data!.length)
                                          ? 'All accounts'
                                          : filtersToReturn.accounts
                                              ?.map((e) => e.name)
                                              .join(', '),
                                  onClick: () async {
                                    final modalRes = await showModalBottomSheet<
                                        List<Account>>(
                                      context: context,
                                      builder: (context) {
                                        return AccountSelector(
                                          allowMultiSelection: true,
                                          filterSavingAccounts: false,
                                          selectedAccounts:
                                              filtersToReturn.accounts ??
                                                  (snapshot.hasData
                                                      ? [...snapshot.data!]
                                                      : []),
                                        );
                                      },
                                    );

                                    if (modalRes != null &&
                                        modalRes.isNotEmpty) {
                                      setState(() {
                                        filtersToReturn.accounts =
                                            snapshot.hasData &&
                                                    modalRes.length ==
                                                        snapshot.data!.length
                                                ? null
                                                : modalRes;
                                      });
                                    }
                                  });
                            }),
                      ],
                    ),
                  ),
                  BottomSheetFooter(
                      onSaved: () => Navigator.of(context).pop(filtersToReturn))
                ],
              ),
              const SizedBox(height: 22),
            ],
          ),
        ]),
      ),
    );
  }
}
