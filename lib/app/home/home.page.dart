import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/accounts/account_details.dart';
import 'package:finlytics/app/accounts/account_form.dart';
import 'package:finlytics/app/budgets/budgets_page.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/home/card_with_header.dart';
import 'package:finlytics/app/home/circular_arc.dart';
import 'package:finlytics/app/settings/settings.page.dart';
import 'package:finlytics/app/stats/widgets/balance_bar_chart_small.dart';
import 'package:finlytics/app/stats/widgets/chart_by_categories.dart';
import 'package:finlytics/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/app/stats/widgets/incomeOrExpenseCard.dart';
import 'package:finlytics/app/transactions/transaction_form.page.dart';
import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/app/transactions/transactions.page.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/services/finance_health_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

import '../../core/presentation/widgets/user_avatar.dart';
import '../stats/stats_page.dart';
import '../transactions/recurrent_transactions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.calculate_outlined,
      'label': t.budgets.title,
      'route': const BudgetsPage()
    },
    {
      'icon': Icons.sell_outlined,
      'label': 'Categories',
      'route': const CategoriesList(mode: CategoriesListMode.page)
    },
    {
      'icon': Icons.repeat_rounded,
      'label': 'Trans. recurrents',
      'route': const RecurrentTransactionPage()
    },
    {
      'icon': Icons.settings_outlined,
      'label': 'Settings',
      'route': const SettingsPage()
    },
  ];

  final dateRangeService = DateRangeService();

  late Stream<List<Account>> _accountsStream;

  @override
  void initState() {
    super.initState();

    _accountsStream = AccountService.instance.getAccounts();

    dateRangeService.resetDateRanges();
  }

  Widget buildAccountList(List<Account> accounts) {
    return Builder(
      builder: (context) {
        if (accounts.isEmpty) {
          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Aun no hay cuentas creadas',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Empieza a usar toda la magia de Finlytics. Crea al menos una cuenta para empezar a añadir tranacciones.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountFormPage())),
                          child: Text(t.account.form.create))
                    ],
                  ))
            ],
          );
        }

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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetailsPage(
                              account: account,
                              prevPage: const HomePage(),
                            ))),
                leading: Hero(
                    tag: 'account-icon-${account.id}',
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(1000)),
                        child: account.icon.display(
                            size: 22, color: Theme.of(context).primaryColor))),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              percentage: snapshot.data!,
                              decimalDigits: 0,
                            );
                          }),
                    ]),
                title: Text(account.name),
              );
            });
      },
    );
  }

  _showShouldCreateAccountWarn() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ops!'),
          content: const SingleChildScrollView(
              child: Text(
                  'You should create an account first to create this action perform this action')),
          actions: [
            TextButton(
              child: const Text('Go for that!'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountFormPage()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final t = Translations.of(context);

    final accountService = AccountService.instance;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_rounded),
          onPressed: () {
            AccountService.instance.getAccounts(limit: 1).first.then((value) {
              if (value.isEmpty) {
                _showShouldCreateAccountWarn();
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransactionFormPage()));
              }
            });
          }),
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
                          onPressed: () {
                            dateRangeService
                                .openDateModal(context)
                                .then((_) => setState(() {}));
                          },
                          label: Text(
                            dateRangeService.selectedDateRange
                                .currentText(context),
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
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.home.total_balance,
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
                              Text(t.home.total_balance,
                                  style: const TextStyle(fontSize: 12)),
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
                                    }

                                    return const Skeleton(
                                        width: 90, height: 40);
                                  }),
                              if (dateRangeService.startDate != null &&
                                  dateRangeService.endDate != null)
                                StreamBuilder(
                                    stream: accountService
                                        .getAccountsMoneyVariation(
                                            accounts: accounts.data!,
                                            startDate:
                                                dateRangeService.startDate,
                                            endDate: dateRangeService.endDate,
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
                        IncomeOrExpenseCard(
                          type: AccountDataFilter.income,
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        IncomeOrExpenseCard(
                          type: AccountDataFilter.expense,
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                        stream: _accountsStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CardWithHeader(
                                title: t.general.accounts,
                                body: const LinearProgressIndicator());
                          } else {
                            final accounts = snapshot.data!;

                            return CardWithHeader(
                                title: t.general.accounts,
                                headerButtonIcon: Icons.add_rounded,
                                onHeaderButtonClick: accounts.isEmpty
                                    ? null
                                    : () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AccountFormPage()));
                                      },
                                body: buildAccountList(accounts));
                          }
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    StreamBuilder(
                        stream: AccountService.instance.getAccounts(limit: 1),
                        builder: (context, accountSnapshot) {
                          return CardWithHeader(
                            title: t.home.last_transactions,
                            onHeaderButtonClick: accountSnapshot.hasData &&
                                    accountSnapshot.data!.isNotEmpty
                                ? () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TransactionsPage()));
                                  }
                                : null,
                            body: StreamBuilder(
                                stream: TransactionService.instance
                                    .getTransactions(
                                        predicate: (transaction,
                                                account,
                                                accountCurrency,
                                                receivingAccount,
                                                receivingAccountCurrency,
                                                c,
                                                p6) =>
                                            DatabaseImpl.instance.buildExpr([
                                              if (dateRangeService.startDate !=
                                                  null)
                                                transaction.date
                                                    .isBiggerOrEqualValue(
                                                        dateRangeService
                                                            .startDate!),
                                              if (dateRangeService.endDate !=
                                                  null)
                                                transaction.date
                                                    .isSmallerThanValue(
                                                        dateRangeService
                                                            .endDate!)
                                            ]),
                                        limit: 5,
                                        orderBy: (p0, p1, p2, p3, p4, p5, p6) =>
                                            drift.OrderBy([
                                              drift.OrderingTerm(
                                                  expression: p0.date,
                                                  mode: drift.OrderingMode.desc)
                                            ])),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const LinearProgressIndicator();
                                  }

                                  if (snapshot.data!.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        t.transaction.list.empty,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return TransactionListComponent(
                                      transactions: snapshot.data!,
                                      showGroupDivider: false,
                                      prevPage: const HomePage());
                                }),
                          );
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    CardWithHeader(
                      title: t.financial_health.display,
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
                        title: 'Tendencia de saldo',
                        body: FundEvolutionLineChart(
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                          dateRange: dateRangeService.selectedDateRange,
                        ),
                        onHeaderButtonClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StatsPage(
                                        initialIndex: 1,
                                      )));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: t.stats.by_categories,
                        body: ChartByCategories(
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        onHeaderButtonClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StatsPage(
                                        initialIndex: 0,
                                      )));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: t.stats.cash_flow,
                        body: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16),
                          child: BalanceChartSmall(
                              dateRangeService: dateRangeService),
                        ),
                        onHeaderButtonClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StatsPage(
                                        initialIndex: 2,
                                      )));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                      title: 'Enlaces rápidos',
                      body: GridView.count(
                        primary: false,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 8,
                        crossAxisCount: 4,
                        children: _tools
                            .map((item) => Column(
                                  children: [
                                    IconButton.filledTonal(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      item['route']));
                                        },
                                        icon: Icon(
                                          item['icon'],
                                          size: 32,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['label'],
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    )
                                  ],
                                ))
                            .toList(),
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
