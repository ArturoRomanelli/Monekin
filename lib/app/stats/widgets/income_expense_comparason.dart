import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/presentation/widgets/animated_progress_bar.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class IncomeExpenseComparason extends StatelessWidget {
  const IncomeExpenseComparason({super.key, this.startDate, this.endDate});

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AccountService.instance.getAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final accounts = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Balance"),
                      StreamBuilder(
                        stream: AccountService.instance.getAccountsData(
                            accountIds: accounts.map((e) => e.id),
                            accountDataFilter: AccountDataFilter.balance,
                            startDate: startDate,
                            endDate: endDate),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Skeleton(width: 35, height: 32);
                          }

                          return CurrencyDisplayer(
                              amountToConvert: snapshot.data!,
                              textStyle:
                                  Theme.of(context).textTheme.headlineSmall!);
                        },
                      )
                    ],
                  )
                ]),
              ),
              StreamBuilder(
                stream: Rx.combineLatest2(
                    AccountService.instance.getAccountsData(
                        accountIds: accounts.map((e) => e.id),
                        accountDataFilter: AccountDataFilter.income,
                        startDate: startDate,
                        endDate: endDate),
                    AccountService.instance.getAccountsData(
                        accountIds: accounts.map((e) => e.id),
                        accountDataFilter: AccountDataFilter.expense,
                        startDate: startDate,
                        endDate: endDate),
                    (a, b) => [a, b]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final income = snapshot.data![0];
                  final expense = snapshot.data![1].abs();

                  return Column(children: [
                    ListTile(
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Income"),
                              CurrencyDisplayer(amountToConvert: income)
                            ],
                          ),
                          AnimatedProgressBar(
                              value: income + expense > 0
                                  ? (income / (income + expense))
                                  : 0,
                              color: Colors.green),
                        ])),
                    ListTile(
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Expense"),
                              CurrencyDisplayer(amountToConvert: expense)
                            ],
                          ),
                          AnimatedProgressBar(
                              value: income + expense > 0
                                  ? (expense / (income + expense))
                                  : 0,
                              color: Colors.red),
                        ]))
                  ]);
                },
              ),
            ],
          );
        });
  }
}
