import 'package:collection/collection.dart';
import 'package:finlytics/app/accounts/account_form.dart';
import 'package:finlytics/app/home/card_with_header.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/animated_progress_bar.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AccountWithMoney {
  final double money;
  final Account account;

  AccountWithMoney({required this.money, required this.account});
}

class CurrencyWithMoney {
  double money;
  final CurrencyInDB currency;

  CurrencyWithMoney({required this.money, required this.currency});
}

class AllAccountBalancePage extends StatefulWidget {
  const AllAccountBalancePage({super.key, required this.date});

  final DateTime date;

  @override
  State<AllAccountBalancePage> createState() => _AllAccountBalancePageState();
}

Stream<List<AccountWithMoney>> getAccountsWithMoney(DateTime date) {
  final accounts = AccountService.instance.getAccounts();
  final balances = accounts.asyncMap((accountList) => Future.wait(
      accountList.map((account) => AccountService.instance
          .getAccountMoney(
              account: account, convertToPreferredCurrency: true, date: date)
          .first)));

  return Rx.combineLatest2(accounts, balances, (accounts, balances) {
    final toReturn = accounts
        .mapIndexed((index, element) =>
            AccountWithMoney(money: balances[index], account: element))
        .toList();

    toReturn.sort((a, b) => b.money.compareTo(a.money));

    return toReturn;
  });
}

List<CurrencyWithMoney> getCurrenciesWithMoney(
    List<AccountWithMoney> accountsWithMoney) {
  final toReturn = <CurrencyWithMoney>[];

  for (final account in accountsWithMoney) {
    final currencyToPush = toReturn.firstWhereOrNull(
        (e) => e.currency.code == account.account.currency.code);

    if (currencyToPush != null) {
      currencyToPush.money += account.money;
    } else {
      toReturn.add(CurrencyWithMoney(
          money: account.money, currency: account.account.currency));
    }
  }

  toReturn.sort((a, b) => b.money.compareTo(a.money));

  return toReturn;
}

Widget emptyAccountsIndicator() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    child: Text(t.account.no_accounts, textAlign: TextAlign.center),
  );
}

class _AllAccountBalancePageState extends State<AllAccountBalancePage> {
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return StreamBuilder(
        stream: getAccountsWithMoney(widget.date),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }
          final accounts = snapshot.data!;

          final totalMoney = accounts.map((e) => e.money).sum;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardWithHeader(
                title: t.stats.balance_by_account,
                body: accounts.isEmpty
                    ? emptyAccountsIndicator()
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final accountWithMoney = accounts[index];

                          return ListTile(
                            leading: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(1000)),
                                child: accountWithMoney.account.icon.display(
                                    size: 22,
                                    color: Theme.of(context).primaryColor)),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AccountFormPage(
                                  prevPage:
                                      AllAccountBalancePage(date: widget.date),
                                  account: accountWithMoney.account,
                                ),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(accountWithMoney.account.name),
                                    CurrencyDisplayer(
                                        amountToConvert: accountWithMoney.money)
                                  ],
                                ),
                                AnimatedProgressBar(
                                    value: accountWithMoney.money / totalMoney),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(indent: 56);
                        },
                        itemCount: accounts.length,
                        shrinkWrap: true,
                      ),
              ),
              const SizedBox(height: 16),
              CardWithHeader(
                title: t.stats.balance_by_currency,
                body: Builder(builder: (context) {
                  final currenciesWithMoney = getCurrenciesWithMoney(accounts);

                  if (currenciesWithMoney.isEmpty) {
                    return emptyAccountsIndicator();
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final currencyWithMoney = currenciesWithMoney[index];

                      return ListTile(
                        leading: StreamBuilder(
                          stream: CurrencyService.instance.getCurrencyByCode(
                              currencyWithMoney.currency.code),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Skeleton(width: 42, height: 42);
                            }

                            final currency = snapshot.data!;

                            return Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: currency.displayFlagIcon(size: 42));
                          },
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StreamBuilder(
                                    stream: CurrencyService.instance
                                        .getCurrencyByCode(
                                            currencyWithMoney.currency.code),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Skeleton(
                                            width: 42, height: 42);
                                      }

                                      final currency = snapshot.data!;

                                      return Text(currency.name);
                                    }),
                                CurrencyDisplayer(
                                    amountToConvert: currencyWithMoney.money)
                              ],
                            ),
                            AnimatedProgressBar(
                                value: currencyWithMoney.money / totalMoney),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(indent: 56);
                    },
                    itemCount: currenciesWithMoney.length,
                    shrinkWrap: true,
                  );
                }),
              ),
            ],
          );
        });
  }
}
