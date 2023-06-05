import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/services/view-actions/transaction_view_actions_service.dart';
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
      {super.key,
      required this.transaction,
      required this.prevPage,
      this.recurrentMode = false});

  final MoneyTransaction transaction;

  /// Widget to navigate if the transaction is removed
  final Widget prevPage;

  /// If true, it will display some info about the recurrency of a transaction
  final bool recurrentMode;

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  @override
  void initState() {
    super.initState();

    if (widget.recurrentMode && widget.transaction is! MoneyRecurrentRule) {
      throw Exception(
          'A single/normal transaction can not be passed when recurrentMode is true');
    }
  }

  Widget statusDisplayer(MoneyTransaction transaction) {
    if (transaction.status == null && transaction is! MoneyRecurrentRule) {
      throw Exception('Error');
    }

    final bool showRecurrencyStatus =
        (transaction is MoneyRecurrentRule) && widget.recurrentMode;

    final color = showRecurrencyStatus
        ? Theme.of(context).primaryColor
        : transaction.status!.color;

    return Card(
      elevation: 1,
      color: color.lighten(0.385),
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Icon(
                  showRecurrencyStatus
                      ? Icons.repeat_rounded
                      : transaction.status?.icon,
                  size: 26,
                  color: color.darken(0.2),
                )
              ],
            ),
          ),
          Divider(color: color.lighten(0.25)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                    'Esta transacción ha sido validada ya y se corresponde con una transacción real de su banco'),
                if (transaction.status == TransactionStatus.pending)
                  const SizedBox(height: 12),
                if (transaction.status == TransactionStatus.pending)
                  Row(
                    children: [
                      if (widget.transaction is MoneyRecurrentRule) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => false,
                            child: Text('Saltar pago'),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: color.darken(0.2)),
                                backgroundColor: Colors.white.withOpacity(0.6),
                                foregroundColor: color.darken(0.2)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: () => false,
                          child: Text('Pagar'),
                          style: FilledButton.styleFrom(
                              backgroundColor: color.darken(0.2)),
                        ),
                      ),
                    ],
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
    final transactionDetailsActions = TransactionViewActionService()
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
                        currency: widget.transaction.account.currency,
                        textStyle: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.transaction.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!widget.recurrentMode)
                        Text(
                          DateFormat.yMMMMd()
                              .add_Hm()
                              .format(widget.transaction.date),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(widget.transaction as MoneyRecurrentRule).recurrencyData.formText} ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
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
              if (widget.transaction.status != null ||
                  widget.transaction is MoneyRecurrentRule)
                statusDisplayer(widget.transaction),
              CardWithHeader(
                title: 'Datos',
                body: SizedBox(
                  width: double.infinity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          //contentPadding: const EdgeInsets.all(2),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cuenta'),
                              Chip(
                                  label: Text(widget.transaction.account.name),
                                  padding: const EdgeInsets.all(2),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.12),
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: widget.transaction.account.icon
                                        .display(
                                            color:
                                                Theme.of(context).primaryColor),
                                  )),
                            ],
                          ),
                        ),
                        const Divider(indent: 12),
                        ListTile(
                          //contentPadding: const EdgeInsets.all(2),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.transaction.isIncomeOrExpense
                                  ? 'Category'
                                  : 'Cuenta de destino'),
                              Chip(
                                  label: Text(
                                      widget.transaction.isIncomeOrExpense
                                          ? widget.transaction.category!.name
                                          : widget.transaction.receivingAccount!
                                              .name),
                                  padding: const EdgeInsets.all(2),
                                  labelStyle: TextStyle(
                                      color: widget.transaction
                                          .color(context)
                                          .darken()),
                                  side: BorderSide(
                                      color: widget.transaction
                                          .color(context)
                                          .darken()),
                                  backgroundColor: widget.transaction
                                      .color(context)
                                      .withOpacity(0.12),
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: widget.transaction.isIncomeOrExpense
                                        ? widget.transaction.category!.icon
                                            .display(
                                                color: widget.transaction
                                                    .color(context))
                                        : widget
                                            .transaction.receivingAccount!.icon
                                            .display(
                                                color: widget.transaction
                                                    .color(context)),
                                  )),
                            ],
                          ),
                        ),
                        if (widget.transaction.notes != null)
                          const Divider(indent: 12),
                        if (widget.transaction.notes != null)
                          ListTile(
                            title: Text('Note'),
                            subtitle: Text(widget.transaction.notes!),
                          )
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              CardWithHeader(
                title: 'Acciones rápidas',
                body: Column(
                  children: [
                    GridView.count(
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                                  )
                                ],
                              ))
                          .toList(),
                    ),
                    if (!widget.recurrentMode &&
                        (widget.transaction is MoneyRecurrentRule))
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '* Esta transacción ha sido autogenerada a raiz de una regla recurrente. Por ello, al editar o eliminarla afectarás a todas las futuras transacciones que se puedan generar con esta regla',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                      )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
