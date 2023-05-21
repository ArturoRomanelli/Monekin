import 'package:finlytics/app/tabs/widgets/balance_bar_chart.dart';
import 'package:finlytics/app/tabs/widgets/chart_by_categories.dart';
import 'package:finlytics/app/tabs/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/utils/date_getter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Tab3Page extends StatefulWidget {
  const Tab3Page({Key? key}) : super(key: key);

  @override
  State<Tab3Page> createState() => _Tab3PageState();
}

class _Tab3PageState extends State<Tab3Page> {
  List<DateTime?>? currentDateRange;

  int initialIndex = 500;
  late PageController _pageController;

  DateTime? selectedTabDate;

  TransactionType selectedTypeForCategoriesChart = TransactionType.expense;

  final dateRangeService = DateRangeService();

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: initialIndex);

    setState(() {
      selectedTabDate = dateRangeService.getCurrentDateRange()[0];
    });
  }

  Widget incomeOrExpenseIndicator(
      AccountDataFilter type, DateTime? startDate, DateTime? endDate) {
    final Color color =
        type == AccountDataFilter.income ? Colors.green : Colors.red;
    final String text = type == AccountDataFilter.income ? 'Income' : 'Expense';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.75,
              color: color.withOpacity(0.8),
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            Icons.arrow_upward,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            StreamBuilder(
                stream: AccountService.instance.getAccounts(),
                builder: (context, accounts) {
                  if (!accounts.hasData) {
                    return const Skeleton(width: 20, height: 12);
                  }

                  return StreamBuilder(
                      stream: AccountService.instance.getAccountsData(
                        accountIds: accounts.data!.map((e) => e.id),
                        startDate: startDate,
                        endDate: endDate,
                        accountDataFilter: type,
                        convertToPreferredCurrency: true,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Skeleton(width: 20, height: 12);
                        }

                        return CurrencyDisplayer(
                          amountToConvert: snapshot.data!,
                          showDecimals: false,
                        );
                      });
                })
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hello Tab 2'), elevation: 3, actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () async {
            await dateRangeService.openDateModal(context);
            _pageController
                .animateToPage(initialIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                .then((value) {
              setState(() {});
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Do something
          },
        ),
      ]),
      body: Column(
        children: [
          AppBar(
              title: Builder(builder: (context) {
                String text = '';

                if (selectedTabDate == null) return Text(text);

                final selectedDateRange = dateRangeService.selectedDateRange;

                if (selectedDateRange == DateRange.monthly) {
                  if (selectedTabDate!.year == currentYear) {
                    text = DateFormat.MMMM().format(selectedTabDate!);
                  } else {
                    text = DateFormat.yMMMM().format(selectedTabDate!);
                  }
                } else if (selectedDateRange == DateRange.annualy) {
                  text = DateFormat.y().format(selectedTabDate!);
                } else if (selectedDateRange == DateRange.quaterly) {
                  text =
                      "Q${(selectedTabDate!.month / 3).ceil()} - ${selectedTabDate!.year}";
                }

                return Text(text);
              }),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                  icon: const Icon(Icons.keyboard_arrow_left)),
              actions: [
                IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    icon: const Icon(Icons.keyboard_arrow_right)),
              ]),
          Expanded(
            child: PageView.builder(
              //  physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemCount: 10000,
              onPageChanged: (newPage) {
                selectedTabDate =
                    dateRangeService.getDateRange(newPage - initialIndex)[0];

                setState(() {});
              },
              itemBuilder: (context, index) {
                final dateRanges =
                    dateRangeService.getDateRange(index - initialIndex);

                final DateTime? startDate = dateRanges[0];
                final DateTime? endDate = dateRanges[1];

                return SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text('Gastos e ingresos',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                incomeOrExpenseIndicator(
                                    AccountDataFilter.income,
                                    startDate,
                                    endDate),
                                incomeOrExpenseIndicator(
                                    AccountDataFilter.expense,
                                    startDate,
                                    endDate),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Cash-flow',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  BalanceBarChart(
                                    startDate: startDate,
                                    dateRange:
                                        dateRangeService.selectedDateRange,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('By categories',
                                          style: TextStyle(fontSize: 18)),
                                      PopupMenuButton(
                                        child: Chip(
                                          labelPadding:
                                              const EdgeInsets.fromLTRB(
                                                  8, 0, 2, 0),
                                          padding: const EdgeInsets.all(2),
                                          label: Row(
                                            children: [
                                              Text(
                                                  selectedTypeForCategoriesChart ==
                                                          TransactionType
                                                              .expense
                                                      ? 'Gasto'
                                                      : 'Ingreso'),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.arrow_drop_down)
                                            ],
                                          ),
                                        ),
                                        itemBuilder: (context) {
                                          return <PopupMenuEntry<
                                              TransactionType>>[
                                            const PopupMenuItem(
                                                value: TransactionType.expense,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  minLeadingWidth: 26,
                                                  title: Text('Expense'),
                                                )),
                                            const PopupMenuDivider(height: 0),
                                            const PopupMenuItem(
                                                value: TransactionType.income,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  minLeadingWidth: 26,
                                                  title: Text('Income'),
                                                )),
                                          ];
                                        },
                                        onSelected: (value) {
                                          setState(() {
                                            selectedTypeForCategoriesChart =
                                                value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                ChartByCategories(
                                  startDate: startDate,
                                  endDate: endDate,
                                  transactionsType:
                                      selectedTypeForCategoriesChart,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Fund evolution',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  FundEvolutionLineChart(
                                    startDate: startDate,
                                    endDate: endDate,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
