import 'dart:math';

import 'package:collection/collection.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/date_getter.dart';
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
      {super.key, required this.startDate, required this.dateRange});

  final DateTime? startDate;
  final DateRange dateRange;

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

    final accounts = await accountService.getAccounts().first;
    final accountsIds = accounts.map((event) => event.id);

    final selectedDateRange = widget.dateRange;

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

        final incomeToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.income,
                startDate: startDate,
                endDate: endDate)
            .first;

        final expenseToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.expense,
                startDate: startDate,
                endDate: endDate)
            .first;

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    } else if (selectedDateRange == DateRange.annualy) {
      for (var i = 1; i <= 12; i++) {
        final startDate = DateTime(currentYear, i);
        final endDate = DateTime(currentYear, i + 1);

        shortTitles.add(DateFormat.M().format(startDate));
        longTitles.add(DateFormat.MMMM().format(startDate));

        final incomeToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.income,
                startDate: startDate,
                endDate: endDate)
            .first;

        final expenseToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.expense,
                startDate: startDate,
                endDate: endDate)
            .first;

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    } else if (selectedDateRange == DateRange.quaterly) {
      for (var i = startDate.month; i < startDate.month + 3; i++) {
        final startDate = DateTime(currentYear, i);
        final endDate = DateTime(currentYear, i + 1);

        shortTitles.add(DateFormat.MMM().format(startDate));
        longTitles.add(DateFormat.MMMM().format(startDate));

        final incomeToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.income,
                startDate: startDate,
                endDate: endDate)
            .first;

        final expenseToAdd = await accountService
            .getAccountsData(
                accountIds: accountsIds,
                accountDataFilter: AccountDataFilter.expense,
                startDate: startDate,
                endDate: endDate)
            .first;

        income.add(incomeToAdd);
        expense.add(expenseToAdd);
        balance.add(incomeToAdd + expenseToAdd);
      }
    }

    return IncomeExpenseChartDataItem(
        income: income,
        expense: expense,
        balance: balance,
        shortTitles: shortTitles,
        longTitles: longTitles);
  }

  BarChartGroupData makeGroupData(
    int x,
    double income,
    double expense, {
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    bool isTouched = touchedBarGroupIndex == x;

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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
        BarChartRodData(
          toY: expense,
          color: isTouched && touchedRodDataIndex == 1
              ? Colors.red.darken(0.1)
              : Colors.red,
          width: width,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
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
                  tooltipBgColor: Colors.white,
                  tooltipHorizontalAlignment: FLHorizontalAlignment.right,
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
                        space: 16,
                        child: Text(
                          snapshot.data!.shortTitles[value.toInt()],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    },
                    reservedSize: 38,
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
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
              ),
              barGroups: List.generate(snapshot.data!.income.length, (i) {
                return makeGroupData(
                    i, snapshot.data!.income[i], snapshot.data!.expense[i]);
              }),
            ));
          }),
    );
  }
}
