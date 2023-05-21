import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListComponent extends StatelessWidget {
  const TransactionListComponent(
      {super.key, required this.transactions, this.showGroupDivider = true});

  final List<MoneyTransaction> transactions;

  final bool showGroupDivider;

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
            trailing: StreamBuilder(
              stream: CurrencyService.instance
                  .getCurrencyByCode(transaction.account.currencyId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Skeleton(width: 40, height: 12);
                }

                return CurrencyDisplayer(
                  amountToConvert: transaction.value,
                  currency: snapshot.data!,
                  textStyle: TextStyle(
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : transaction.type == TransactionType.expense
                              ? Colors.red
                              : null,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: transaction.isIncomeOrExpense
                      ? ColorHex.get(transaction.category!.color)
                          .withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6)),
              child: transaction.isIncomeOrExpense
                  ? SupportedIconService.instance
                      .getIconByID(transaction.category!.iconId)
                      .display(
                          color: ColorHex.get(transaction.category!.color!),
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
