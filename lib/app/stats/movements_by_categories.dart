import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/tabs/widgets/chart_by_categories.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';

class MovementsByCategoryPage extends StatefulWidget {
  const MovementsByCategoryPage({super.key});

  @override
  State<MovementsByCategoryPage> createState() =>
      _MovementsByCategoryPageState();
}

class _MovementsByCategoryPageState extends State<MovementsByCategoryPage> {
  final dateRangeService = DateRangeService();

  TransactionType transactionsType = TransactionType.expense;

  late DateTime? currentStartDate;
  late DateTime? currentEndDate;
  late DateRange? currentDateRange;

  /// If null, will get the stats for all the accounts of the user
  List<Account>? accountsToFilter;

  @override
  void initState() {
    super.initState();

    final dates = dateRangeService.getDateRange(0);

    currentStartDate = dates[0];
    currentEndDate = dates[1];
    currentDateRange = dateRangeService.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos por categoría"),
        actions: [
          IconButton(
              onPressed: () async {
                final modalRes = await showModalBottomSheet<TransactionFilters>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FilterSheetModal(
                        preselectedFilter:
                            TransactionFilters(accounts: accountsToFilter)));

                if (modalRes != null) {
                  setState(() {
                    accountsToFilter = modalRes.accounts;
                  });
                }
              },
              icon: const Icon(Icons.filter_alt_outlined))
        ],
      ),
      persistentFooterButtons: [
        FooterSegmentedCalendarButton(
          onDateRangeChanged: (newStartDate, newEndDate, newDateRange) {
            setState(() {
              currentStartDate = newStartDate;
              currentEndDate = newEndDate;
              currentDateRange = newDateRange;
            });
          },
        )
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SegmentedButton(
                segments: const <ButtonSegment>[
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Gastos'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Ingresos'),
                  ),
                ],
                showSelectedIcon: false,
                selected: {transactionsType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    transactionsType = newSelection.first;
                  });
                },
              ),
            ),
            ChartByCategories(
                startDate: currentStartDate,
                endDate: currentEndDate,
                showList: true,
                transactionsType: transactionsType,
                accountsToFilter: accountsToFilter),
          ],
        ),
      ),
    );
  }
}
