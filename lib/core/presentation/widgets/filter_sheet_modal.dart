import 'package:finlytics/app/accounts/account_selector.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class TransactionFilters {
  List<Account>? accounts;
  List<Category>? categories;

  TransactionFilters({this.accounts, this.categories});
}

class FilterSheetModal extends StatefulWidget {
  const FilterSheetModal(
      {super.key,
      required this.preselectedFilter,
      this.showCategoryFilter = true});

  final TransactionFilters preselectedFilter;

  final bool showCategoryFilter;

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
    final t = Translations.of(context);

    return TextField(
        controller:
            TextEditingController(text: inputValue ?? t.general.unspecified),
        readOnly: true,
        onTap: () => onClick(),
        decoration: InputDecoration(
          labelText: title,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
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
                  /* ---------------------------------- */
                  /* -------- ACCOUNT SELECTOR -------- */
                  /* ---------------------------------- */

                  StreamBuilder(
                      stream: AccountService.instance.getAccounts(),
                      builder: (context, snapshot) {
                        return selector(
                            title: t.general.accounts,
                            inputValue: filtersToReturn.accounts == null ||
                                    (snapshot.hasData &&
                                        filtersToReturn.accounts!.length ==
                                            snapshot.data!.length)
                                ? 'All accounts'
                                : filtersToReturn.accounts
                                    ?.map((e) => e.name)
                                    .join(', '),
                            onClick: () async {
                              final modalRes =
                                  await showAccountSelectorBottomSheet(
                                      context,
                                      AccountSelector(
                                        allowMultiSelection: true,
                                        filterSavingAccounts: false,
                                        selectedAccounts:
                                            filtersToReturn.accounts ??
                                                (snapshot.hasData
                                                    ? [...snapshot.data!]
                                                    : []),
                                      ));

                              if (modalRes != null && modalRes.isNotEmpty) {
                                setState(() {
                                  filtersToReturn.accounts = snapshot.hasData &&
                                          modalRes.length ==
                                              snapshot.data!.length
                                      ? null
                                      : modalRes;
                                });
                              }
                            });
                      }),
                  if (widget.showCategoryFilter) const SizedBox(height: 16),

                  /* ---------------------------------- */
                  /* -------- CATEGORY SELECTOR ------- */
                  /* ---------------------------------- */

                  if (widget.showCategoryFilter)
                    StreamBuilder(
                        stream: CategoryService.instance.getMainCategories(),
                        builder: (context, snapshot) {
                          return selector(
                              title: t.general.categories,
                              inputValue: filtersToReturn.categories == null ||
                                      (snapshot.hasData &&
                                          filtersToReturn.categories!.length ==
                                              snapshot.data!.length)
                                  ? 'All categories'
                                  : filtersToReturn.categories
                                      ?.map((e) => e.name)
                                      .join(', '),
                              onClick: () async {
                                final modalRes =
                                    await showModalBottomSheet<List<Category>>(
                                  context: context,
                                  builder: (context) {
                                    return CategoriesList(
                                      mode: CategoriesListMode
                                          .modalSelectMultiCategory,
                                      selectedCategories:
                                          filtersToReturn.categories ??
                                              (snapshot.hasData
                                                  ? [...snapshot.data!]
                                                  : []),
                                    );
                                  },
                                );

                                if (modalRes != null && modalRes.isNotEmpty) {
                                  setState(() {
                                    filtersToReturn.categories =
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
    );
  }
}
