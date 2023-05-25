import 'package:collection/collection.dart';
import 'package:finlytics/app/accounts/accountForm.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/animated_progress_bar.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
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
  const AllAccountBalancePage({super.key});

  @override
  State<AllAccountBalancePage> createState() => _AllAccountBalancePageState();
}

Stream<List<AccountWithMoney>> getAccountsWithMoney() {
  final accounts = AccountService.instance.getAccounts();
  final balances = accounts.asyncMap((accountList) => Future.wait(
      accountList.map((account) =>
          AccountService.instance.getAccountMoney(account: account).first)));

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

class _AllAccountBalancePageState extends State<AllAccountBalancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis cuentas')),
      persistentFooterButtons: [
        PersistentFooterButton(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountFormPage()));
            },
            icon: const Icon(Icons.add),
            label: const Text('Añadir cuenta'),
          ),
        )
      ],
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: getAccountsWithMoney(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final accounts = snapshot.data!;

              final totalMoney = accounts.map((e) => e.money).sum;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Saldo por cuentas'),
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final accountWithMoney = accounts[index];

                      return ListTile(
                        leading: accountWithMoney.account.icon.display(),
                        onTap: () => false,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const Divider(),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Saldo por divisas'),
                  ),
                  Builder(builder: (context) {
                    final currenciesWithMoney =
                        getCurrenciesWithMoney(accounts);

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                ],
              );
            }),
      ),
    );
  }
}
