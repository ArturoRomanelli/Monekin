import 'package:collection/collection.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/services/transaction/transaction_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChartByCategoriesDataItem {
  Category category;
  List<MoneyTransaction> transactions;
  double value;

  ChartByCategoriesDataItem({
    required this.category,
    required this.transactions,
    required this.value,
  });
}

class ChartByCategories extends StatefulWidget {
  const ChartByCategories(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.transactionsType});

  final DateTime? startDate;
  final DateTime? endDate;

  final TransactionType transactionsType;

  @override
  State<ChartByCategories> createState() => _ChartByCategoriesState();
}

class _ChartByCategoriesState extends State<ChartByCategories> {
  Future<List<ChartByCategoriesDataItem>?> getEvolutionData(
    BuildContext context,
  ) async {
    if (widget.startDate == null || widget.endDate == null) return null;

    final data = <ChartByCategoriesDataItem>[];

    final accountService = context.read<MoneyTransactionService>();

    final transactions = await accountService.getMoneyTransactions(
      startDate: widget.startDate,
      endDate: widget.endDate,
      minValue: widget.transactionsType == TransactionType.income ? 0 : null,
      maxValue: widget.transactionsType == TransactionType.expense ? 0 : null,
    );

    for (var transaction in transactions) {
      final categoryToEdit = data.firstWhereOrNull((cat) =>
          cat.category.id == transaction.category?.id ||
          cat.category.id == transaction.category?.parentCategory?.id);

      if (categoryToEdit != null) {
        categoryToEdit.value += transaction.value.abs();
        categoryToEdit.transactions.add(transaction);
      } else {
        data.add(ChartByCategoriesDataItem(
            category: transaction.category!.isMainCategory
                ? transaction.category!
                : transaction.category!.parentCategory!,
            transactions: [transaction],
            value: transaction.value.abs()));
      }
    }

    data.sort((a, b) => b.value.compareTo(a.value));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getEvolutionData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final dataCategory = snapshot.data![index];

            const barRadius = BorderRadius.only(
              topRight: Radius.circular(2),
              bottomRight: Radius.circular(2),
            );

            return ListTile(
              title: Text(dataCategory.category.name),
              subtitle: Container(
                  height: 12,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: barRadius,
                      color: ColorHex.get(dataCategory.category.color)
                          .withOpacity(0.12)),
                  child: FractionallySizedBox(
                    widthFactor: dataCategory.value /
                        snapshot.data!
                            .map((e) => e.value)
                            .reduce((value, element) => value + element),
                    heightFactor: 1,
                    alignment: FractionalOffset.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: barRadius,
                        color: ColorHex.get(dataCategory.category.color),
                      ),
                    ),
                  )),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: ColorHex.get(dataCategory.category.color)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6)),
                child: dataCategory.category.icon.display(
                    color: ColorHex.get(dataCategory.category.color), size: 28),
              ),
              trailing: Container(
                  width: 42,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: Text(
                    NumberFormat.decimalPercentPattern().format(
                      (dataCategory.value /
                          snapshot.data!
                              .map((e) => e.value)
                              .reduce((value, element) => value + element)),
                    ),
                    textAlign: TextAlign.end,
                  )),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
