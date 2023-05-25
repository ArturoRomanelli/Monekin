import 'package:finlytics/app/transactions/transaction_details.page.dart';
import 'package:finlytics/core/database/services/transaction/transaction_UIActions_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListComponent extends StatelessWidget {
  const TransactionListComponent(
      {super.key,
      required this.transactions,
      this.showGroupDivider = true,
      required this.prevPage});

  final List<MoneyTransaction> transactions;

  final bool showGroupDivider;

  final Widget prevPage;

  showTransactionActions(BuildContext context, MoneyTransaction transaction) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        builder: (context) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              children: (TransactionUIActionService()
                  .transactionDetailsActions(context, transaction: transaction)
                  .map((e) => ListTile(
                        leading: Icon(e.icon),
                        title: Text(e.label),
                        onTap: () {
                          Navigator.pop(context);
                          e.onClick();
                        },
                      ))).toList());
        });
  }

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
            if (!showGroupDivider) return Container();
            return dateSeparator(transactions[0].date);
          }

          final transaction = transactions[index - 1];

          return ListTile(
            title: Row(
              children: [
                Text(transaction.isIncomeOrExpense
                    ? transaction.category!.name
                    : 'Transfer'),
                const SizedBox(width: 4),
                if (transaction.status == TransactionStatus.reconcilied)
                  const Icon(
                    Icons.check_circle,
                    color: Color.fromARGB(255, 40, 110, 43),
                    size: 12,
                  )
              ],
            ),
            subtitle: Text(
              '${transaction.account.name} • ${DateFormat.yMMMd().format(transaction.date)} • ${DateFormat.Hm().format(transaction.date)} ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            trailing: CurrencyDisplayer(
              amountToConvert: transaction.value,
              currency: transaction.account.currency,
              textStyle: TextStyle(
                  color: transaction.type == TransactionType.income
                      ? Colors.green
                      : transaction.type == TransactionType.expense
                          ? Colors.red
                          : null,
                  fontWeight: FontWeight.bold),
            ),
            leading: Hero(
              tag: 'transaction-icon-${transaction.id}',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: transaction.color(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6)),
                child: transaction.isIncomeOrExpense
                    ? transaction.category!.icon.display(
                        color: transaction.color(context),
                        size: 28,
                      )
                    : const Icon(Icons.swap_vert, size: 28),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionDetailsPage(
                            transaction: transaction,
                            prevPage: prevPage,
                          )));
            },
            onLongPress: () => showTransactionActions(context, transaction),
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0 ||
              transactions.isEmpty ||
              index >= transactions.length) {
            return Container();
          }

          if (!showGroupDivider ||
              index >= 1 &&
                  DateUtils.isSameDay(
                      transactions[index - 1].date, transactions[index].date)) {
            return const Divider(indent: 68);
          }

          return dateSeparator(transactions[index].date);
        });
  }
}
