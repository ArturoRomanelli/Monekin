import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/tabs/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';

class FundEvolutionPage extends StatefulWidget {
  const FundEvolutionPage({super.key});

  @override
  State<FundEvolutionPage> createState() => _FundEvolutionPageState();
}

class _FundEvolutionPageState extends State<FundEvolutionPage> {
  final dateRangeService = DateRangeService();

  late DateTime? currentStartDate;
  late DateTime? currentEndDate;
  late DateRange? currentDateRange;

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
    final accountService = AccountService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Evolución del saldo")),
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
              StreamBuilder(
                  stream: accountService.getAccounts(),
                  builder: (context, accounts) {
                    if (!accounts.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Final balance - ${dateRangeService.getTextOfRange(startDate: currentStartDate, endDate: currentEndDate, dateRange: currentDateRange)}',
                              style: const TextStyle(fontSize: 12)),
                          const Skeleton(width: 70, height: 40),
                          const Skeleton(width: 30, height: 14),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Final balance - ${dateRangeService.getTextOfRange(startDate: currentStartDate, endDate: currentEndDate)}',
                              style: const TextStyle(fontSize: 12)),
                          StreamBuilder(
                              stream: accountService.getAccountsMoney(
                                  accountIds: accounts.data!.map((e) => e.id),
                                  date: currentEndDate),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Skeleton(width: 70, height: 40);
                                }

                                return CurrencyDisplayer(
                                    amountToConvert: snapshot.data!,
                                    textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600));
                              }),
                          if (currentStartDate != null &&
                              currentEndDate != null)
                            StreamBuilder(
                                stream:
                                    accountService.getAccountsMoneyVariation(
                                        accounts: accounts.data!,
                                        startDate: currentStartDate,
                                        endDate: currentEndDate,
                                        convertToPreferredCurrency: true),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Skeleton(
                                        width: 52, height: 22);
                                  }

                                  return TrendingValue(
                                    percentage: snapshot.data!,
                                    filled: true,
                                    fontWeight: FontWeight.bold,
                                    outlined: true,
                                  );
                                }),
                        ],
                      );
                    }
                  }),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                return FundEvolutionLineChart(
                    startDate: currentStartDate, endDate: currentEndDate);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
