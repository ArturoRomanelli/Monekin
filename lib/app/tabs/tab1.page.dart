import 'package:finlytics/app/accounts/accountForm.dart';
import 'package:finlytics/app/settings/settings.page.dart';
import 'package:finlytics/app/tabs/circular_arc.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
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

  final dateRangeService = DateRangeService.instance;

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
                            DateRangeService.instance
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        incomeOrExpenseIndicator(AccountDataFilter.income),
                        incomeOrExpenseIndicator(AccountDataFilter.expense)
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
                    child: StreamBuilder(
                        stream: accountService.getAccounts(),
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
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text('Salud financiera',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Card(
                          elevation: 1,
                          clipBehavior: Clip.hardEdge,
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 3,
                                      child: Text(
                                          'lockjdf fdjivcfd cofd fdoinc c dfo fvdf vif fvofin v dfv nfdlknvklfvfd vfiofnvdf vdfnvfd vfdkbvdf vdfbvf')),
                                  Flexible(
                                      flex: 2,
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        print("cdukcdkjdc");
                                        print(constraints.maxWidth);
                                        print(constraints.maxHeight);
                                        return CircularArc(
                                          value: 0.2,
                                          size: constraints.maxWidth * 0.45,
                                        );
                                      }))
                                ],
                              )),
                        ),
                        const SizedBox(height: 16),
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
                                              builder: (context) =>
                                                  item['route']))
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
