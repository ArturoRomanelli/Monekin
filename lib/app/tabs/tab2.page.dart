import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/presentation/widgets/empty_indicator.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:flutter/material.dart';

class Tab2Page extends StatefulWidget {
  const Tab2Page({Key? key}) : super(key: key);

  @override
  State<Tab2Page> createState() => _Tab2PageState();
}

class _Tab2PageState extends State<Tab2Page> {
  TransactionFilters filters = TransactionFilters();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Transactions'),
          // foregroundColor: Theme.of(context).colorScheme.onPrimary,
          // backgroundColor: Theme.of(context).primaryColor,
          elevation: 4,
          actions: [
            IconButton(
                onPressed: () async {
                  final modalRes =
                      await showModalBottomSheet<TransactionFilters>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) =>
                              FilterSheetModal(preselectedFilter: filters));

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined)),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Do something
              },
            ),
          ]),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: TransactionService.instance.getTransactions(
                predicate: (t, account, accountCurrency, receivingAccount,
                        receivingAccountCurrency, c, p6) =>
                    DatabaseImpl.instance.buildExpr([
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
                    children: [
                      LinearProgressIndicator(),
                    ],
                  );
                }

                final transactions = snapshot.data!;

                if (transactions.isEmpty) {
                  return const Column(
                    children: [
                      Expanded(
                          child: EmptyIndicator(
                              title: 'Ops! Esto esta muy vacio',
                              description:
                                  'Añade una transacción pulsando el botón inferior para empezar a ver valores aquí')),
                    ],
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: TransactionListComponent(
                    transactions: transactions,
                    prevPage: const TabsPage(currentPageIndex: 1),
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
