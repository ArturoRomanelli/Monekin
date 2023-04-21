import 'package:finlytics/pages/accounts/accountForm.dart';
import 'package:finlytics/pages/settings/settings.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/exchangeRates/exchange_rate.service.dart';
import 'package:finlytics/widgets/currency_displayer.dart';
import 'package:finlytics/widgets/skeleton.dart';
import 'package:finlytics/widgets/trending_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Tab1Page extends StatefulWidget {
  const Tab1Page({Key? key}) : super(key: key);

  @override
  State<Tab1Page> createState() => _Tab1PageState();
}

class _Tab1PageState extends State<Tab1Page> {
  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.business,
      'label': 'Business',
    },
    {
      'icon': Icons.school,
      'label': 'School',
    },
    {
      'icon': Icons.settings_outlined,
      'label': 'Settings',
      'route': const SettingsPage()
    },
  ];

  Widget accountItemInSwiper(Account account) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.transparent, width: 2),
              ),
              child: SizedBox(
                  height: 28,
                  width: 28,
                  child: SvgPicture.asset(
                    account.icon.urlToAssets,
                    fit: BoxFit.contain,
                  ))),
          const SizedBox(
            width: 10,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    FutureBuilder(
                        initialData: 0.0,
                        future: context
                            .watch<AccountService>()
                            .getAccountMoney(account: account),
                        builder: (context, snapshot) {
                          return CurrencyDisplayer(
                            amountToConvert: snapshot.data!,
                            currency: account.currency,
                          );
                        }),
                    const SizedBox(
                      width: 12,
                    ),
                    FutureBuilder(
                        initialData: 0.0,
                        future: context
                            .watch<AccountService>()
                            .getAccountsMoneyVariation(
                                accounts: [account],
                                convertToPreferredCurrency: false),
                        builder: (context, snapshot) {
                          return TrendingValue(
                              percentage: snapshot.data!, decimalDigits: 0);
                        }),
                  ],
                )
              ]),
        ],
      ),
    );
  }

  Widget accountList(List<Account>? accounts) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: (accounts?.length ?? 0) + 1,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(left: index == 0 ? 12 : 2),
          width: 250.0,
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async => {
                await Future.delayed(const Duration(milliseconds: 200)),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountFormPage(
                            accountUUID: (index == (accounts?.length ?? 0))
                                ? null
                                : accounts![index].id)))
              },
              child: (index == (accounts?.length ?? 0))
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                          Icon(Icons.add),
                          Text('Create account'),
                        ])
                  : accountItemInSwiper(accounts![index]),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Rebuild when a exchange rate change
    context.select((ExchangeRateService p) => setState(() => {}));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Good evening,',
                                  style: TextStyle(fontSize: 12)),
                              Text('user', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          ActionChip(
                            // TODO: ActionChip not show ripple effect when a background color is applied.
                            // This is a known issue of flutter, see:
                            // - https://github.com/flutter/flutter/issues/73215
                            // - https://github.com/flutter/flutter/issues/115824

                            onPressed: () {
                              false;
                            },
                            label: Text(
                              'Este mes',
                              style: TextStyle(color: colors.onPrimary),
                            ),
                            avatar: Icon(
                              Icons.calendar_month,
                              color: colors.onPrimary,
                            ),
                            side: BorderSide(color: colors.onPrimary),
                            backgroundColor: Theme.of(context).primaryColor,
                          )
                        ]),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 8,
                    ),
                    FutureBuilder(
                        future: context.watch<AccountService>().getAccounts(),
                        builder: (context, accounts) {
                          if (!accounts.hasData) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total balance',
                                    style: TextStyle(fontSize: 12)),
                                const Skeleton(width: 70, height: 40),
                              ],
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total balance',
                                    style: TextStyle(fontSize: 12)),
                                FutureBuilder(
                                    future: context
                                        .watch<AccountService>()
                                        .getAccountsMoney(
                                            accounts: accounts.data!),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return CurrencyDisplayer(
                                            amountToConvert: snapshot.data!,
                                            textStyle: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.w600));
                                      } else {
                                        return const Skeleton(
                                            width: 70, height: 40);
                                      }
                                    }),
                                FutureBuilder(
                                    initialData: 0.0,
                                    future: context
                                        .watch<AccountService>()
                                        .getAccountsMoneyVariation(
                                            accounts: accounts.data!,
                                            convertToPreferredCurrency: true),
                                    builder: (context, snapshot) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 230, 255, 230),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: TrendingValue(
                                            percentage: snapshot.data!),
                                      );
                                    }),
                              ],
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My accounts'),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountFormPage()))
                          },
                          child: const Text('See all'),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: FutureBuilder(
                        future: context.watch<AccountService>().getAccounts(),
                        builder: (context, accounts) {
                          if (!accounts.hasData) {
                            return const LinearProgressIndicator();
                          } else {
                            return accountList(accounts.data);
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(16),
                              child: const Text('Tools',
                                  style: TextStyle(fontSize: 18))),
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _tools.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = _tools[index];

                              return ListTile(
                                title: Text(item['label']),
                                leading: Icon(
                                  item['icon'],
                                  color: Theme.of(context).primaryColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => item['route']))
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
