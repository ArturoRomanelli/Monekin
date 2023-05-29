import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/filter_sheet_modal.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      this.showList = false,
      this.transactionsType = TransactionType.expense,
      this.filters});

  final DateTime? startDate;
  final DateTime? endDate;

  final bool showList;

  final TransactionType transactionsType;

  final TransactionFilters? filters;

  @override
  State<ChartByCategories> createState() => _ChartByCategoriesState();
}

class _ChartByCategoriesState extends State<ChartByCategories> {
  int touchedIndex = -1;

  Future<List<ChartByCategoriesDataItem>?> getEvolutionData(
    BuildContext context,
  ) async {
    if (widget.startDate == null || widget.endDate == null) return null;

    final data = <ChartByCategoriesDataItem>[];

    final transactionService = TransactionService.instance;

    final transactions = await transactionService
        .getTransactions(
          predicate: (t, acc, p2, p3, p4, transCategory, p6) =>
              DatabaseImpl.instance.buildExpr([
            t.receivingAccountID.isNull(),
            if (widget.startDate != null)
              t.date.isBiggerThanValue(widget.startDate!),
            if (widget.endDate != null)
              t.date.isSmallerThanValue(widget.endDate!),
            if (widget.filters?.accounts != null)
              t.accountID.isIn(widget.filters!.accounts!.map((e) => e.id)),
            if (widget.filters?.categories != null)
              transCategory.id
                      .isIn(widget.filters!.categories!.map((e) => e.id)) |
                  transCategory.parentCategoryID
                      .isIn(widget.filters!.categories!.map((e) => e.id)),
            if (widget.transactionsType == TransactionType.income)
              t.value.isBiggerOrEqualValue(0),
            if (widget.transactionsType == TransactionType.expense)
              t.value.isSmallerOrEqualValue(0)
          ]),
        )
        .first;

    for (final transaction in transactions) {
      final categoryToEdit = data.firstWhereOrNull((cat) =>
          cat.category.id == transaction.category?.id ||
          cat.category.id == transaction.category?.parentCategoryID);

      if (categoryToEdit != null) {
        categoryToEdit.value += transaction.value.abs();
        categoryToEdit.transactions.add(transaction);
      } else {
        data.add(ChartByCategoriesDataItem(
            category: transaction.category!.parentCategoryID == null
                ? Category.fromDB(transaction.category!, null)
                : (await CategoryService.instance
                    .getCategoryById(transaction.category!.parentCategoryID!)
                    .first)!,
            transactions: [transaction],
            value: transaction.value.abs()));
      }
    }

    data.sort((a, b) => b.value.compareTo(a.value));
    return data;
  }

  /// Returns a value between 0 and 100
  double getElementPercentageInTotal(
      double elementValue, List<ChartByCategoriesDataItem> items) {
    return (elementValue /
        items.map((e) => e.value).reduce((value, element) => value + element));
  }

  List<ChartByCategoriesDataItem> deleteUnimportantItems(
      List<ChartByCategoriesDataItem> data) {
    const limit = 0.05;

    final unimportantItems = data.where(
        (element) => getElementPercentageInTotal(element.value, data) < limit);

    if (unimportantItems.length <= 1) return data;

    final toReturn = data
        .where((element) =>
            getElementPercentageInTotal(element.value, data) >= limit)
        .toList();

    final toAdd = ChartByCategoriesDataItem(
        value: 0,
        transactions: [],
        category: Category(
            id: 'Other',
            name: 'Other',
            iconId: 'iconId',
            type: CategoryType.B,
            color: 'DEDEDE'));

    for (var item in unimportantItems) {
      toAdd.value += item.value;
      toAdd.transactions = [...toAdd.transactions, ...item.transactions];
    }

    toReturn.add(toAdd);

    return toReturn;
  }

  List<PieChartSectionData> showingSections(
      List<ChartByCategoriesDataItem> data) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.175),
          value: 100,
          radius: 50,
          showTitle: false,
        )
      ];
    }

    return data.mapIndexed((index, element) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      final percentage = getElementPercentageInTotal(element.value, data);

      return PieChartSectionData(
        color: ColorHex.get(element.category.color),
        value: percentage,
        title: NumberFormat.percentPattern().format(percentage),
        radius: radius,
        titleStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget indicator({
    required Color color,
    required String text,
    required bool isSquare,
    double size = 12,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getEvolutionData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final filteredDataItems = deleteUnimportantItems(snapshot.data!);

        return Column(
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: <Widget>[
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(filteredDataItems),
                    ),
                  ),
                  if (snapshot.data!.isEmpty)
                    const Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text("Datos insuficientes")),
                    ),
                ],
              ),
            ),

            /* ----------------------------- */
            /* ------- CHART LEGEND -------- */
            /* ----------------------------- */

            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
              child: Wrap(
                spacing: 10, // gap between adjacent cards
                runSpacing: 2, // gap between lines
                alignment: WrapAlignment.center,
                children: filteredDataItems
                    .map((e) => indicator(
                        color: ColorHex.get(e.category.color),
                        text: e.category.name,
                        isSquare: false))
                    .toList(),
              ),
            ),

            /* ----------------------------- */
            /* ------ Info in a list ------- */
            /* ----------------------------- */

            if (widget.showList)
              ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dataCategory = snapshot.data![index];

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dataCategory.category.name),
                        CurrencyDisplayer(amountToConvert: dataCategory.value)
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${dataCategory.transactions.length} transacciones'),
                        Text(
                            NumberFormat.decimalPercentPattern(decimalDigits: 2)
                                .format(getElementPercentageInTotal(
                                    dataCategory.value, snapshot.data!)))
                      ],
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: ColorHex.get(dataCategory.category.color)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6)),
                      child: dataCategory.category.icon.display(
                          color: ColorHex.get(dataCategory.category.color),
                          size: 28),
                    ),
                    onTap: () {},
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
