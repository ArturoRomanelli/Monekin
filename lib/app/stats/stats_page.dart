import 'package:finlytics/app/accounts/all_accounts_balance.dart';
import 'package:finlytics/app/home/card_with_header.dart';
import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/stats/widgets/balance_bar_chart.dart';
import 'package:finlytics/app/stats/widgets/chart_by_categories.dart';
import 'package:finlytics/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/app/stats/widgets/income_expense_comparason.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
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
    return Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stats'),
          bottom: TabBar(tabs: [
            Tab(text: 'Por categorías'),
            Tab(text: 'Saldo'),
            Tab(text: 'Flujo de fondos'),
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
        body: TabBarView(children: [
          ChartByCategories(
              startDate: currentStartDate,
              endDate: currentEndDate,
              showList: true,
              initialSelectedType: TransactionType.income,
              filters: filters),
          buildContainerWithPadding(
            [
              CardWithHeader(
                title: 'Tendencia de saldo',
                body: FundEvolutionLineChart(
                  showBalanceHeader: true,
                  startDate: currentStartDate,
                  endDate: currentEndDate,
                  dateRange: currentDateRange,
                  //accountsFilter: accountsToFilter,
                ),
              ),
              const SizedBox(height: 16),
              const AllAccountBalancePage(),
            ],
          ),
          buildContainerWithPadding([
            CardWithHeader(
              title: 'Flujo de fondos',
              body: IncomeExpenseComparason(
                startDate: currentStartDate,
                endDate: currentEndDate,
              ),
            ),
            const SizedBox(height: 16),
            CardWithHeader(
              title: 'Por periodos',
              body: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 16),
                child: BalanceBarChart(
                    startDate: currentStartDate, dateRange: currentDateRange),
              ),
            )
          ]),
        ]),
      ),
    );
  }
}
