import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/core/database/services/transaction/transaction_UIActions_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailAction {
  final String label;
  final IconData icon;

  final void Function() onClick;

  TransactionDetailAction({
    required this.label,
    required this.icon,
    required this.onClick,
  });
}

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage(
      {super.key, required this.transaction, required this.prevPage});

  final MoneyTransaction transaction;

  /// Widget to navigate if the transaction is removed
  final Widget prevPage;

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  Widget statusDisplayer(TransactionStatus status) {
    return Card(
      elevation: 1,
      color: status.color.lighten(0.425),
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transacción reconciliada',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Icon(
                  status.icon,
                  size: 26,
                  color: status.color.darken(0.2),
                )
              ],
            ),
          ),
          Divider(color: status.color.lighten(0.325)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                    "Esta transacción ha sido validada ya y se corresponde con una transacción real de su banco"),
                if (status == TransactionStatus.pending)
                  const SizedBox(height: 12),
                if (status == TransactionStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => false,
                      child: Text("Pagar"),
                      style: FilledButton.styleFrom(
                          backgroundColor: status.color.darken(0.2)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionDetailsActions = TransactionUIActionService()
        .transactionDetailsActions(context,
            transaction: widget.transaction, prevPage: widget.prevPage);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrencyDisplayer(
                        amountToConvert: widget.transaction.value,
                        textStyle: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.transaction.note ??
                            widget.transaction.category!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMMd()
                            .add_Hm()
                            .format(widget.transaction.date),
                      )
                    ],
                  ),
                  Hero(
                    tag: 'transaction-icon-${widget.transaction.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            widget.transaction.color(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.transaction.isIncomeOrExpense
                          ? widget.transaction.category!.icon.display(
                              color: widget.transaction.color(context),
                              size: 42,
                            )
                          : const Icon(Icons.swap_vert, size: 42),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              if (widget.transaction.status != null)
                statusDisplayer(widget.transaction.status!),
              CardWithHeader(
                title: 'Datos',
                body: SizedBox(
                  width: double.infinity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          //contentPadding: const EdgeInsets.all(2),
                          title: Text('Cuenta'),

                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SupportedIconService.instance
                                  .getIconByID(
                                      widget.transaction.account.iconId)
                                  .display(size: 16),
                              const SizedBox(width: 4),
                              Text(widget.transaction.account.name),
                            ],
                          ),
                        ),
                        const Divider(indent: 12),
                        ListTile(
                          //contentPadding: const EdgeInsets.all(2),
                          title: Text('Category'),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SupportedIconService.instance
                                  .getIconByID(
                                      widget.transaction.category!.iconId)
                                  .display(size: 16),
                              const SizedBox(width: 4),
                              Text(widget.transaction.category!.name),
                            ],
                          ),
                        ),
                        if (widget.transaction.note != null)
                          const Divider(indent: 12),
                        if (widget.transaction.note != null)
                          ListTile(
                            title: Text("Note"),
                            subtitle: Text(widget.transaction.note!),
                          )
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              CardWithHeader(
                title: 'Acciones rápidas',
                body: GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 8,
                  crossAxisCount: 4,
                  children: transactionDetailsActions
                      .map((item) => Column(
                            children: [
                              IconButton.filledTonal(
                                  onPressed: item.onClick,
                                  icon: Icon(
                                    item.icon,
                                    size: 32,
                                    color: Theme.of(context).primaryColor,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                              )
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
          )),
    );
  }
}
