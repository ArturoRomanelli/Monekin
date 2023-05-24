import 'package:async/async.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BalanceChartSmall extends StatefulWidget {
  const BalanceChartSmall({super.key, required this.dateRangeService});

  final DateRangeService dateRangeService;

  @override
  State<BalanceChartSmall> createState() => _BalanceChartSmallState();
}

class _BalanceChartSmallState extends State<BalanceChartSmall> {
  int touchedGroupIndex = -1;

  BarChartGroupData makeGroupData(int x, double expense, double income) {
    const double width = 56;

    const radius = BorderRadius.vertical(
        bottom: Radius.zero, top: Radius.circular(width / 6));

    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: expense,
          color: x == 0 ? Colors.red.withOpacity(0.4) : Colors.red,
          borderRadius: radius,
          width: width,
        ),
        BarChartRodData(
          toY: income,
          color: x == 0 ? Colors.green.withOpacity(0.4) : Colors.green,
          borderRadius: radius,
          width: width,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: StreamBuilder(
          stream: AccountService.instance.getAccounts(),
          builder: (context, accountsSnapshot) {
            if (!accountsSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return StreamBuilder(
                stream: StreamZip([
                  AccountService.instance.getAccountsData(
                    accountIds: accountsSnapshot.data!.map((e) => e.id),
                    accountDataFilter: AccountDataFilter.expense,
                    startDate: widget.dateRangeService.getDateRange(-1)[0],
                    endDate: widget.dateRangeService.getDateRange(-1)[1],
                  ),
                  AccountService.instance.getAccountsData(
                    accountIds: accountsSnapshot.data!.map((e) => e.id),
                    accountDataFilter: AccountDataFilter.income,
                    startDate: widget.dateRangeService.getDateRange(-1)[0],
                    endDate: widget.dateRangeService.getDateRange(-1)[1],
                  ),
                  AccountService.instance.getAccountsData(
                    accountIds: accountsSnapshot.data!.map((e) => e.id),
                    accountDataFilter: AccountDataFilter.expense,
                    startDate: widget.dateRangeService.startDate,
                    endDate: widget.dateRangeService.endDate,
                  ),
                  AccountService.instance.getAccountsData(
                    accountIds: accountsSnapshot.data!.map((e) => e.id),
                    accountDataFilter: AccountDataFilter.income,
                    startDate: widget.dateRangeService.startDate,
                    endDate: widget.dateRangeService.endDate,
                  ),
                ]),
                builder: (context, snapshpot) {
                  if (!snapshpot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          getTooltipItem: (a, b, c, d) => null,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value == 0
                                    ? 'Periodo anterior'
                                    : 'Este periodo',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                          show: true,
                          border: const Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.black12))),
                      barGroups: [
                        makeGroupData(
                            0, -snapshpot.data![0], snapshpot.data![1]),
                        makeGroupData(
                            1, -snapshpot.data![2], snapshpot.data![3]),
                      ],
                      gridData: FlGridData(show: false),
                    ),
                  );
                });
          }),
    );
  }
}
