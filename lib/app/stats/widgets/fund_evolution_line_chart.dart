import 'package:collection/collection.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FundEvolutionChartDataItem {
  List<double> balance;
  List<String> labels;

  FundEvolutionChartDataItem({required this.balance, required this.labels});
}

class FundEvolutionLineChart extends StatefulWidget {
  const FundEvolutionLineChart(
      {super.key,
      required this.startDate,
      required this.endDate,
      this.accountsFilter});

  final DateTime? startDate;
  final DateTime? endDate;

  final List<Account>? accountsFilter;

  @override
  State<FundEvolutionLineChart> createState() => _FundEvolutionLineChartState();
}

class _FundEvolutionLineChartState extends State<FundEvolutionLineChart> {
  Future<FundEvolutionChartDataItem?> getEvolutionData(
    BuildContext context,
  ) async {
    if (widget.startDate == null || widget.endDate == null) return null;

    List<Future<double>> balance = [];
    List<String> labels = [];

    final accountService = AccountService.instance;

    final accounts =
        widget.accountsFilter ?? await accountService.getAccounts().first;

    DateTime currentDay = DateTime(
        widget.startDate!.year, widget.startDate!.month, widget.startDate!.day);

    final dayRange =
        (widget.endDate!.difference(widget.startDate!).inDays / 100).ceil();

    while (currentDay.compareTo(widget.endDate!) < 0) {
      labels.add(DateFormat.yMMMMd().format(currentDay));

      balance.add(accountService
          .getAccountsMoney(
              accountIds: accounts.map((e) => e.id), date: currentDay)
          .first);

      currentDay = currentDay.add(Duration(days: dayRange));
    }

    return FundEvolutionChartDataItem(
        balance: await Future.wait(balance), labels: labels);
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.lighten(0.3),
    ];

    return SizedBox(
      height: 300,
      child: FutureBuilder(
          future: getEvolutionData(context),
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

            return LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.white,
                tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                tooltipMargin: -10,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final flSpot = barSpot;
                    if (flSpot.x == 0 || flSpot.x == 6) {
                      return null;
                    }

                    return LineTooltipItem(
                        '${snapshot.data!.labels[flSpot.x.toInt()]} \n',
                        const TextStyle(),
                        children: [
                          TextSpan(
                              text:
                                  '${snapshot.data!.balance[flSpot.x.toInt()]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ))
                        ]);
                  }).toList();
                },
              )),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        snapshot.data!.labels[int.parse(meta.formattedValue)],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w200),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) {
                        return Container();
                      }

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
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY:
                  snapshot.data!.balance.min - snapshot.data!.balance.min * 0.1,
              maxY:
                  snapshot.data!.balance.max + snapshot.data!.balance.max * 0.1,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                      snapshot.data!.balance.length,
                      (index) => FlSpot(
                          index.toDouble(), snapshot.data!.balance[index])),
                  isCurved: true,
                  curveSmoothness: 0.025,
                  color: gradientColors[0],
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradientColors
                          .map((color) => color.withOpacity(0.3))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ));
          }),
    );
  }
}