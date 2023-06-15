import 'package:finlytics/app/transactions/transaction_list.dart';
import 'package:finlytics/core/database/services/recurrent-rules/recurrent_rule_service.dart';
import 'package:finlytics/core/presentation/widgets/empty_indicator.dart';
import 'package:finlytics/i18n/translations.g.dart';
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
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.recurrent_transactions.title)),
      body: StreamBuilder(
          stream: RecurrentRuleService.instance.getRecurrentRules(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            final transactions = snapshot.data!;

            if (transactions.isEmpty) {
              return Column(
                children: [
                  Expanded(
                      child: EmptyIndicator(
                          title: 'Ops! Esto esta muy vacio',
                          description: t.recurrent_transactions.empty)),
                ],
              );
            }

            return TransactionListComponent(
                transactions: transactions,
                showRecurrentInfo: true,
                showGroupDivider: false,
                prevPage: const RecurrentTransactionPage());
          }),
    );
  }
}
