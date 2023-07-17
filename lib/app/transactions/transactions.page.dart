import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/home/home.page.dart';
import 'package:finlytics/app/transactions/transaction_form.page.dart';
import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/presentation/widgets/empty_indicator.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  TransactionFilters filters = TransactionFilters();

  bool searchActive = false;

  FocusNode searchFocusNode = FocusNode();
  String? searchValue;

  @override
  void initState() {
    super.initState();

    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        setState(() {
          searchActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
          leading: searchActive
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchActive = false;
                      searchValue = null;
                    });
                  },
                  icon: const Icon(Icons.close))
              : null,
          title: searchActive
              ? TextField(
                  focusNode: searchFocusNode,
                  decoration: InputDecoration(
                      hintText: t.transaction.list.searcher_placeholder,
                      border: const UnderlineInputBorder()),
                  onChanged: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                )
              : Text(t.general.transactions),
          actions: [
            if (!searchActive)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searchActive = true;
                  });

                  searchFocusNode.requestFocus();
                },
              ),
            IconButton(
                onPressed: () async {
                  final modalRes =
                      await showModalBottomSheet<TransactionFilters>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (context) =>
                              FilterSheetModal(preselectedFilter: filters));

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined)),
          ]),
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_rounded),
          label: Text(t.transaction.create),
          onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransactionFormPage(
                              prevPage: TransactionsPage(),
                            )))
              }),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: TransactionService.instance.getTransactions(
                predicate: (t, account, accountCurrency, receivingAccount,
                        receivingAccountCurrency, c, p6) =>
                    DatabaseImpl.instance.buildExpr([
                  if (searchValue != null && searchValue!.isNotEmpty)
                    (t.notes.contains(searchValue!) |
                        t.title.contains(searchValue!) |
                        c.name.contains(searchValue!)),
                  if (filters.accounts != null)
                    t.accountID.isIn(filters.accounts!.map((e) => e.id)),
                  if (filters.categories != null)
                    c.id.isIn(filters.categories!.map((e) => e.id)) |
                        c.parentCategoryID
                            .isIn(filters.categories!.map((e) => e.id)),
                ]),
                orderBy: (p0, p1, p2, p3, p4, p5, p6) => drift.OrderBy([
                  drift.OrderingTerm(
                      expression: p0.date, mode: drift.OrderingMode.desc)
                ]),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [LinearProgressIndicator()],
                  );
                }

                final transactions = snapshot.data!;

                if (transactions.isEmpty) {
                  return Column(
                    children: [
                      Expanded(
                          child: EmptyIndicator(
                              title: t.general.empty_warn,
                              description: t.transaction.list.empty)),
                    ],
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: TransactionListComponent(
                    transactions: transactions,
                    prevPage: const HomePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
