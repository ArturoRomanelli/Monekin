import 'package:finlytics/services/transaction/transaction.model.dart';
import 'package:finlytics/services/utils/colorFromHex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListComponent extends StatelessWidget {
  const TransactionListComponent({super.key, required this.transactions});

  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return ListTile(
            title: Text(transaction.isIncomeOrExpense
                ? transaction.category!.name
                : 'Transfer'),
            subtitle: transaction.text != null && transaction.text!.isNotEmpty
                ? Text(transaction.text!)
                : null,
            trailing: Text(NumberFormat.simpleCurrency(
                    name: transaction.account.currency.code, decimalDigits: 2)
                .format(transaction.value)),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: transaction.isIncomeOrExpense
                      ? ColorHex.get(transaction.category!.color)
                          .withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6)),
              child: transaction.isIncomeOrExpense
                  ? transaction.category!.icon.display(
                      color: ColorHex.get(transaction.category!.color),
                      size: 28)
                  : const Icon(Icons.swap_vert, size: 28),
            ),
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        });
  }
}
