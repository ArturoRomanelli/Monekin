import 'package:finlytics/app/accounts/all_accounts_balance.dart';
import 'package:finlytics/app/home/card_with_header.dart';
import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/stats/widgets/balance_bar_chart.dart';
import 'package:finlytics/app/stats/widgets/chart_by_categories.dart';
import 'package:finlytics/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/app/stats/widgets/income_expense_comparason.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/filter_row_indicator.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

import '../../core/services/filters/date_range_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final dateRangeService = DateRangeService();
  final accountService = AccountService.instance;

  late DateTime? currentStartDate;

  late DateTime? currentEndDate;

  late DateRange currentDateRange;

  TransactionFilters filters = TransactionFilters();

  @override
  void initState() {
    super.initState();

    final dates = dateRangeService.getDateRange(0);

    currentStartDate = dates[0];
    currentEndDate = dates[1];
    currentDateRange = dateRangeService.selectedDateRange;
  }

  Widget buildContainerWithPadding(List<Widget> children) {
    return SingleChildScrollView(
        padding:
            const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.stats.title),
          actions: [
            IconButton(
                onPressed: () async {
                  final modalRes =
                      await showModalBottomSheet<TransactionFilters>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (context) =>
                              FilterSheetModal(preselectedFilter: filters));

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined)),
          ],
          bottom: TabBar(tabs: [
            Tab(text: t.stats.by_categories),
            Tab(text: 'Saldo'),
            Tab(text: t.stats.cash_flow),
          ], isScrollable: true),
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
        body: Column(
          children: [
            if (filters.hasFilter) ...[
              FilterRowIndicator(
                filters: filters,
                onChange: (newFilters) {
                  setState(() {
                    filters = newFilters;
                  });
                },
              ),
              const Divider()
            ],
            Expanded(
              child: TabBarView(children: [
                ChartByCategories(
                  startDate: currentStartDate,
                  endDate: currentEndDate,
                  showList: true,
                  initialSelectedType: TransactionType.income,
                  filters: filters,
                ),
                buildContainerWithPadding(
                  [
                    CardWithHeader(
                      title: t.stats.balance_evolution,
                      body: FundEvolutionLineChart(
                        showBalanceHeader: true,
                        startDate: currentStartDate,
                        endDate: currentEndDate,
                        dateRange: currentDateRange,
                        accountsFilter: filters.accounts,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AllAccountBalancePage(
                      date: currentEndDate ?? DateTime.now(),
                      filters: filters,
                    ),
                  ],
                ),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.cash_flow,
                    body: IncomeExpenseComparason(
                      startDate: currentStartDate,
                      endDate: currentEndDate,
                      filters: filters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: t.stats.by_periods,
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 16),
                      child: BalanceBarChart(
                        startDate: currentStartDate,
                        dateRange: currentDateRange,
                        filters: filters,
                      ),
                    ),
                  )
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
