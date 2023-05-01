import 'package:finlytics/services/transaction/transaction.model.dart';
import 'package:finlytics/services/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListComponent extends StatelessWidget {
  const TransactionListComponent({super.key, required this.transactions});

  final List<MoneyTransaction> transactions;

  Widget dateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(DateFormat.yMMMMd().format(date)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (transactions.isEmpty) return Container();

          if (index == 0) {
            return dateSeparator(transactions[0].date);
          }

          final transaction = transactions[index - 1];

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
            onLongPress: () {},
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0 ||
              transactions.isEmpty ||
              index >= transactions.length) {
            return Container();
          }

          if (index >= 1 &&
              DateUtils.isSameDay(
                  transactions[index - 1].date, transactions[index].date)) {
            return const Divider(indent: 68);
          }

          return dateSeparator(transactions[index].date);
        });
  }
}
