import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/tabs/widgets/balance_bar_chart.dart';
import 'package:finlytics/app/tabs/widgets/incomeOrExpenseCard.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';

class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  final dateRangeService = DateRangeService();

  late DateTime? currentStartDate;
  late DateTime? currentEndDate;
  late DateRange currentDateRange;

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
        title: const Text("Evolución del saldo"),
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IncomeOrExpenseCard(
                    type: AccountDataFilter.income,
                    startDate: currentStartDate,
                    endDate: currentEndDate,
                    accountsToFilter: accountsToFilter,
                  ),
                  IncomeOrExpenseCard(
                    type: AccountDataFilter.expense,
                    startDate: currentStartDate,
                    endDate: currentEndDate,
                    accountsToFilter: accountsToFilter,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BalanceBarChart(
                  startDate: currentStartDate,
                  dateRange: currentDateRange,
                  accountsToFilter: accountsToFilter)
            ],
          ),
        ),
      ),
    );
  }
}
