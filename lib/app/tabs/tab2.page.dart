import 'package:drift/drift.dart' show OrderBy, OrderingTerm, OrderingMode;
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/presentation/widgets/empty_indicator.dart';
import 'package:flutter/material.dart';

class Tab2Page extends StatefulWidget {
  const Tab2Page({Key? key}) : super(key: key);

  @override
  State<Tab2Page> createState() => _Tab2PageState();
}

class _Tab2PageState extends State<Tab2Page> {
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
              icon: const Icon(Icons.search),
              onPressed: () {
                // Do something
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
          Expanded(
            child: StreamBuilder(
              stream: TransactionService.instance.getTransactions(
                orderBy: (p0, p1, p2, p3, p4) => OrderBy([
                  OrderingTerm(expression: p0.date, mode: OrderingMode.desc)
                ]),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
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
