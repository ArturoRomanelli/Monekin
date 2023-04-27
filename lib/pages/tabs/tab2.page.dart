import 'package:finlytics/services/transaction/transaction.model.dart';
import 'package:finlytics/services/transaction/transaction_service.dart';
import 'package:finlytics/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            child: SingleChildScrollView(
              child: FutureBuilder(
                initialData: const <MoneyTransaction>[],
                future: context
                    .watch<MoneyTransactionService>()
                    .getMoneyTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return TransactionListComponent(
                        transactions: snapshot.data!);
                  }

                  return const LinearProgressIndicator();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
