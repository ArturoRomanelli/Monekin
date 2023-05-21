import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/accounts/accountForm.dart';
import 'package:finlytics/app/accounts/all_accounts_balance.dart';
import 'package:finlytics/app/settings/settings.page.dart';
import 'package:finlytics/app/stats/fund_evolution.dart';
import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/app/tabs/circular_arc.dart';
import 'package:finlytics/app/tabs/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/transaction_list.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/services/finance_health_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/presentation/widgets/user_avatar.dart';

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

  final dateRangeService = DateRangeService();

  @override
  void initState() {
    super.initState();

    dateRangeService.resetDateRanges();
  }

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
                    StreamBuilder(
                        initialData: 0.0,
                        stream: AccountService.instance
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
                    StreamBuilder(
                        initialData: 0.0,
                        stream: AccountService.instance
                            .getAccountsMoneyVariation(
                                accounts: [account],
                                startDate: dateRangeService.startDate,
                                endDate: dateRangeService.endDate,
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
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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

  Widget incomeOrExpenseIndicator(AccountDataFilter type) {
    final Color color =
        type == AccountDataFilter.income ? Colors.green : Colors.red;
    final String text = type == AccountDataFilter.income ? 'Income' : 'Expense';

    return Flexible(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text),
                  StreamBuilder(
                      stream: AccountService.instance.getAccounts(),
                      builder: (context, accounts) {
                        if (!accounts.hasData) {
                          return const Skeleton(width: 26, height: 18);
                        }

                        return StreamBuilder(
                            stream: AccountService.instance.getAccountsData(
                              accountIds: accounts.data!.map((e) => e.id),
                              startDate: dateRangeService.startDate,
                              endDate: dateRangeService.endDate,
                              accountDataFilter: type,
                              convertToPreferredCurrency: true,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Skeleton(width: 20, height: 12);
                              }

                              return CurrencyDisplayer(
                                amountToConvert: snapshot.data!,
                                textStyle: const TextStyle(fontSize: 18),
                              );
                            });
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final accountService = AccountService.instance;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage()));
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder(
                                    stream: UserSettingService.instance
                                        .getSetting(SettingKey.avatar),
                                    builder: (context, snapshot) {
                                      return UserAvatar(avatar: snapshot.data);
                                    }),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Good evening,',
                                        style: TextStyle(fontSize: 12)),
                                    StreamBuilder(
                                        stream: UserSettingService.instance
                                            .getSetting(SettingKey.userName),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Skeleton(
                                                width: 70, height: 14);
                                          }

                                          return Text(snapshot.data!,
                                              style: const TextStyle(
                                                  fontSize: 18));
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ActionChip(
                          // TODO: ActionChip not show ripple effect when a background color is applied.
                          // This is a known issue of flutter, see:
                          // - https://github.com/flutter/flutter/issues/73215
                          // - https://github.com/flutter/flutter/issues/115824

                          onPressed: () {
                            dateRangeService
                                .openDateModal(context)
                                .then((_) => setState(() {}));
                          },
                          label: const Text(
                            'Este mes',
                          ),
                          avatar: Icon(
                            Icons.calendar_month,
                            color: colors.onBackground,
                          ),
                        )
                      ]),
                  Divider(
                    height: 32,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  StreamBuilder(
                      stream: accountService.getAccounts(),
                      builder: (context, accounts) {
                        if (!accounts.hasData) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total balance',
                                  style: TextStyle(fontSize: 12)),
                              Skeleton(width: 70, height: 40),
                              Skeleton(width: 30, height: 14),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total balance',
                                  style: TextStyle(fontSize: 12)),
                              StreamBuilder(
                                  stream: accountService.getAccountsMoney(
                                      accountIds:
                                          accounts.data!.map((e) => e.id)),
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
                              StreamBuilder(
                                  stream:
                                      accountService.getAccountsMoneyVariation(
                                          accounts: accounts.data!,
                                          startDate: dateRangeService.startDate,
                                          endDate: dateRangeService.endDate,
                                          convertToPreferredCurrency: true),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        dateRangeService.startDate == null ||
                                        dateRangeService.endDate == null) {
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
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Skeleton(
                                            height: 8, width: 70),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        incomeOrExpenseIndicator(AccountDataFilter.income),
                        incomeOrExpenseIndicator(AccountDataFilter.expense)
                      ],
                    ),
                    const SizedBox(height: 16),
                    CardWithHeader(
                      title: 'Cuentas',
                      onDetailsClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AllAccountBalancePage()));
                      },
                      body: StreamBuilder(
                          stream: accountService.getAccounts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            } else {
                              final accounts = snapshot.data!;

                              return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: accounts.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) {
                                    return const Divider(indent: 56);
                                  },
                                  itemBuilder: (context, index) {
                                    final account = accounts[index];

                                    return ListTile(
                                      onTap: () => false,
                                      leading: SizedBox(
                                          height: 28,
                                          width: 28,
                                          child: SvgPicture.asset(
                                            account.icon.urlToAssets,
                                            fit: BoxFit.contain,
                                          )),
                                      trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            StreamBuilder(
                                                initialData: 0.0,
                                                stream: AccountService.instance
                                                    .getAccountMoney(
                                                        account: account),
                                                builder: (context, snapshot) {
                                                  return CurrencyDisplayer(
                                                    amountToConvert:
                                                        snapshot.data!,
                                                    currency: account.currency,
                                                  );
                                                }),
                                            StreamBuilder(
                                                initialData: 0.0,
                                                stream: AccountService.instance
                                                    .getAccountsMoneyVariation(
                                                        accounts: [account],
                                                        startDate:
                                                            dateRangeService
                                                                .startDate,
                                                        endDate:
                                                            dateRangeService
                                                                .endDate,
                                                        convertToPreferredCurrency:
                                                            false),
                                                builder: (context, snapshot) {
                                                  return TrendingValue(
                                                    percentage: snapshot.data!,
                                                    decimalDigits: 0,
                                                  );
                                                }),
                                          ]),
                                      title: Text(account.name),
                                    );
                                  });
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CardWithHeader(
                      title: 'Salud financiera',
                      body: StreamBuilder(
                          stream: accountService.getAccounts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }

                            final accounts = snapshot.data!;

                            return Padding(
                                padding: const EdgeInsets.all(16),
                                child: StreamBuilder(
                                    stream: FinanceHealthService()
                                        .getHealthyValue(
                                            accounts: accounts,
                                            startDate:
                                                dateRangeService.startDate,
                                            endDate: dateRangeService.endDate),
                                    builder: (context, snapshot) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (snapshot.hasData)
                                            Flexible(
                                                flex: 3,
                                                child: Text(
                                                    'Genial! Tu salud financiera es buena. Visita la pestaña de análisis para ver como ahorrar aun mas!')),
                                          if (!snapshot.hasData)
                                            const Column(
                                              children: [
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                              ],
                                            ),
                                          const SizedBox(width: 24),
                                          if (snapshot.hasData)
                                            Flexible(
                                                flex: 2,
                                                child: LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  return CircularArc(
                                                    color: HSLColor.fromAHSL(
                                                            1,
                                                            snapshot.data!,
                                                            1,
                                                            0.35)
                                                        .toColor(),
                                                    value: snapshot.data! / 100,
                                                    width: constraints.maxWidth,
                                                  );
                                                }))
                                        ],
                                      );
                                    }));
                          }),
                    ),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: 'Gastos mas grandes',
                        body: StreamBuilder(
                          stream: TransactionService.instance.getTransactions(
                            predicate: (p0, p1, p2, p3, p4) =>
                                p0.value.isSmallerThanValue(0),
                            limit: 5,
                            orderBy: (p0, p1, p2, p3, p4) => drift.OrderBy([
                              drift.OrderingTerm(
                                  expression: p0.value,
                                  mode: drift.OrderingMode.asc)
                            ]),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }

                            return TransactionListComponent(
                              transactions: snapshot.data!,
                              showGroupDivider: false,
                            );
                          },
                        )),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: 'Tendencia de saldo',
                        body: FundEvolutionLineChart(
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        onDetailsClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FundEvolutionPage()));
                        }),
                    Card(
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
                    const SizedBox(height: 85)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
