import 'package:finlytics/app/tabs/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FundEvolutionPage extends StatefulWidget {
  const FundEvolutionPage({super.key});

  @override
  State<FundEvolutionPage> createState() => _FundEvolutionPageState();
}

class _FundEvolutionPageState extends State<FundEvolutionPage> {
  final dateRangeService = DateRangeService();
  int multiplier = 0;

  Widget buildArrowButton(
      {required IconData icon,
      required void Function() onPressed,
      required BorderRadiusGeometry borderRadius}) {
    return Expanded(
      child: IconButton.outlined(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Theme.of(context).primaryColor,
        style: ButtonStyle(
          side: MaterialStateProperty.all(
              BorderSide(color: Theme.of(context).primaryColor)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountService = AccountService.instance;

    final dates = dateRangeService.getDateRange(multiplier);

    final currentStartDate = dates[0];
    final currentEndDate = dates[1];

    return Scaffold(
      appBar: AppBar(title: const Text("Evolución del saldo")),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.all(4),
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildArrowButton(
                  icon: Icons.arrow_back,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    multiplier -= 1;
                    setState(() {});
                  },
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                    right: Radius.zero,
                  )),
              Expanded(
                flex: 3,
                child: FilledButton(
                  onPressed: () => dateRangeService
                      .openDateModal(context)
                      .then((value) => setState(() {})),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Builder(builder: (context) {
                        final dates = dateRangeService.getDateRange(multiplier);

                        return Text(dateRangeService.getTextOfRange(
                            startDate: dates[0], endDate: dates[1]));
                      }),
                      Icon(Icons.arrow_drop_down_rounded)
                    ],
                  ),
                ),
              ),
              buildArrowButton(
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    multiplier += 1;
                    setState(() {});
                  },
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                    left: Radius.zero,
                  )),
            ],
          ),
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
                              'Final balance - ${dateRangeService.getTextOfRange(startDate: currentStartDate, endDate: currentEndDate)}',
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
                          StreamBuilder(
                              stream: accountService.getAccountsMoneyVariation(
                                  accounts: accounts.data!,
                                  startDate: currentStartDate,
                                  endDate: currentEndDate,
                                  convertToPreferredCurrency: true),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    currentStartDate == null ||
                                    currentEndDate == null) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: snapshot.data != null
                                            ? snapshot.data! >= 0
                                                ? const Color.fromARGB(
                                                    255, 230, 255, 230)
                                                : const Color.fromARGB(
                                                    255, 255, 230, 230)
                                            : null,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Skeleton(height: 8, width: 70),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: snapshot.data != null
                                          ? snapshot.data! >= 0
                                              ? const Color.fromARGB(
                                                  255, 230, 255, 230)
                                              : const Color.fromARGB(
                                                  255, 255, 230, 230)
                                          : null,
                                      borderRadius: BorderRadius.circular(4)),
                                  child:
                                      TrendingValue(percentage: snapshot.data!),
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
