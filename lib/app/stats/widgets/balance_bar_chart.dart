import 'dart:math';

import 'package:collection/collection.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeExpenseChartDataItem {
  List<double> income;
  List<double> expense;
  List<double> balance;
  List<String> shortTitles;
  List<String> longTitles;

  IncomeExpenseChartDataItem({
    required this.income,
    required this.expense,
    required this.balance,
    required this.shortTitles,
    List<String>? longTitles,
  }) : longTitles = longTitles ?? shortTitles;
}

class BalanceBarChart extends StatefulWidget {
  const BalanceBarChart(
      {super.key,
      required this.startDate,
      required this.dateRange,
      this.filters});

  final DateTime? startDate;
  final DateRange dateRange;

  final TransactionFilters? filters;

  @override
  State<BalanceBarChart> createState() => _BalanceBarChartState();
}

class _BalanceBarChartState extends State<BalanceBarChart> {
  int touchedBarGroupIndex = -1;
  int touchedRodDataIndex = -1;

  Future<IncomeExpenseChartDataItem?> getDataByPeriods(
      BuildContext context, DateTime? startDate) async {
    if (startDate == null) return null;

    List<String> shortTitles = [];
    List<String> longTitles = [];

    List<double> income = [];
    List<double> expense = [];
    List<double> balance = [];

    final accountService = AccountService.instance;

    final accounts =
        widget.filters?.accounts ?? await accountService.getAccounts().first;
    final accountsIds = accounts.map((event) => event.id);

    final selectedDateRange = widget.dateRange;

    getIncomeData(DateTime? startDate, DateTime? endDate) async =>
        await accountService
            .getAccountsData(
                accountIds: accountsIds,
                categoriesIds: widget.filters?.categories?.map((e) => e.id),
                accountDataFilter: AccountDataFilter.income,
                startDate: startDate,
                endDate: endDate)
            .first;

    getExpenseData(DateTime? startDate, DateTime? endDate) async =>
        await accountService
            .getAccountsData(
                accountIds: accountsIds,
                categoriesIds: widget.filters?.categories?.map((e) => e.id),
                accountDataFilter: AccountDataFilter.expense,
                startDate: startDate,
                endDate: endDate)
            .first;

    if (selectedDateRange == DateRange.monthly) {
      for (final range in [
        [1, 6],
        [6, 10],
        [10, 15],
        [15, 20],
        [20, 25],
        [25, null]
      ]) {
        shortTitles.add(
            "${range[0].toString()}-${range[1] != null ? range[1].toString() : ''}");

        startDate = DateTime(startDate!.year, startDate.month, range[0]!);

        DateTime endDate = DateTime(
            startDate.year,
            range[1] == null ? startDate.month + 1 : startDate.month,
            range[1] ?? 1);

        longTitles.add(
            '${DateFormat.MMMd().format(startDate)} - ${DateFormat.MMMd().format(endDate)}');

        final incomeToAdd = await getIncomeData(startDate, endDate);
        final expenseToAdd = await getExpenseData(startDate, endDate);

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    } else if (selectedDateRange == DateRange.annualy) {
      for (var i = 1; i <= 12; i++) {
        final selStartDate = DateTime(startDate.year, i);
        final endDate = DateTime(startDate.year, i + 1);

        shortTitles.add(DateFormat.M().format(selStartDate));
        longTitles.add(DateFormat.MMMM().format(selStartDate));

        final incomeToAdd = await getIncomeData(selStartDate, endDate);
        final expenseToAdd = await getExpenseData(selStartDate, endDate);

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    } else if (selectedDateRange == DateRange.quaterly) {
      for (var i = startDate.month; i < startDate.month + 3; i++) {
        final selStartDate = DateTime(startDate.year, i);
        final endDate = DateTime(startDate.year, i + 1);

        shortTitles.add(DateFormat.MMM().format(selStartDate));
        longTitles.add(DateFormat.MMMM().format(selStartDate));

        final incomeToAdd = await getIncomeData(selStartDate, endDate);
        final expenseToAdd = await getExpenseData(selStartDate, endDate);

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    } else if (selectedDateRange == DateRange.weekly) {
      for (var i = 0; i < DateTime.daysPerWeek; i++) {
        final selStartDate =
            DateTime(startDate.year, startDate.month, startDate.day + i);
        final endDate =
            DateTime(startDate.year, startDate.month, startDate.day + i + 1);

        shortTitles.add(DateFormat.E().format(selStartDate));
        longTitles.add(DateFormat.yMMMEd().format(selStartDate));

        final incomeToAdd = await getIncomeData(selStartDate, endDate);
        final expenseToAdd = await getExpenseData(selStartDate, endDate);

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    }

    //TODO: custom and infinite

    return IncomeExpenseChartDataItem(
      income: income,
      expense: expense,
      balance: balance,
      shortTitles: shortTitles,
      longTitles: longTitles,
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double income,
    double expense, {
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    bool isTouched = touchedBarGroupIndex == x;

    Radius radius = Radius.circular(width / 6);

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          toY: income,
          color: isTouched && touchedRodDataIndex == 0
              ? Colors.green.darken(0.1)
              : Colors.green,
          width: width,
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
          ),
        ),
        BarChartRodData(
          toY: expense,
          color: isTouched && touchedRodDataIndex == 1
              ? Colors.red.darken(0.1)
              : Colors.red,
          width: width,
          borderRadius: BorderRadius.only(
            bottomLeft: radius,
            bottomRight: radius,
          ),
        )
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FutureBuilder(
          future: getDataByPeriods(context, widget.startDate),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ],
              );
            }

            return BarChart(BarChartData(
              maxY: max(100, snapshot.data!.income.max),
              minY: min(-100, snapshot.data!.expense.min),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipMargin: -10,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${snapshot.data!.longTitles[group.x]}\n',
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: (rod.toY - 1).toString(),
                          style: TextStyle(
                            color: rod.toY > 0 ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (event, barTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    touchedBarGroupIndex = -1;
                    touchedRodDataIndex = -1;
                    return;
                  }

                  touchedBarGroupIndex =
                      barTouchResponse.spot!.touchedBarGroupIndex;

                  touchedRodDataIndex =
                      barTouchResponse.spot!.touchedRodDataIndex;

                  setState(() {});
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          snapshot.data!.shortTitles[value.toInt()],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          meta.formattedValue,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    },
                    reservedSize: 46,
                  ),
                ),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: const Border(
                      bottom: BorderSide(width: 1, color: Colors.black12))),
              gridData: FlGridData(
                drawVerticalLine: false,
              ),
              barGroups: List.generate(snapshot.data!.income.length, (i) {
                return makeGroupData(
                    i, snapshot.data!.income[i], snapshot.data!.expense[i],
                    width: 142 / snapshot.data!.income.length);
              }),
            ));
          }),
    );
  }
}
