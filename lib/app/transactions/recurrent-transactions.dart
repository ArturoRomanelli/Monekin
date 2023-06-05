import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/core/database/services/recurrent-rules/recurrent_rule_service.dart';
import 'package:finlytics/core/presentation/widgets/empty_indicator.dart';
import 'package:flutter/material.dart';

class RecurrentTransactionPage extends StatefulWidget {
  const RecurrentTransactionPage({super.key});

  @override
  State<RecurrentTransactionPage> createState() =>
      _RecurrentTransactionPageState();
}

class _RecurrentTransactionPageState extends State<RecurrentTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transacciones recurrentes")),
      body: StreamBuilder(
          stream: RecurrentRuleService.instance.getRecurrentRules(),
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

            return TransactionListComponent(
                transactions: transactions,
                showRecurrentInfo: true,
                prevPage: const RecurrentTransactionPage());
          }),
    );
  }
}
