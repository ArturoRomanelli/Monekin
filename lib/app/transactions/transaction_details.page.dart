import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/services/view-actions/transaction_view_actions_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/list_tile_action_item.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slang/builder/utils/string_extensions.dart';

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
  late MoneyTransaction transaction;

  @override
  void initState() {
    super.initState();

    transaction = widget.transaction;

    if (widget.recurrentMode && widget.transaction is! MoneyRecurrentRule) {
      throw Exception(
          'A single/normal transaction can not be passed when recurrentMode is true');
    }
  }

  List<ListTileActionItem> _getPayActions(BuildContext context) {
    final t = Translations.of(context);

    payTransaction(DateTime datetime) {
      TransactionService.instance
          .insertOrUpdateTransaction(transaction.copyWith(
              date: datetime, status: const drift.Value(null)))
          .then((value) {
        if (value <= 0) return;

        TransactionService.instance
            .getTransactionById(transaction.id)
            .first
            .then((value) {
          if (value == null) return;

          setState(() {
            transaction = value;
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.transaction.edit_success)));
        });
      });
    }

    return [
      ListTileActionItem(
        label:
            'Pay in the required date (${DateFormat.yMd().format(transaction.date)})',
        icon: Icons.today_rounded,
        onClick: () => payTransaction(transaction.date),
      ),
      ListTileActionItem(
        label: 'Pay today',
        icon: Icons.event_available_rounded,
        onClick: () => payTransaction(DateTime.now()),
      ),
    ];
  }

  showPayModal(BuildContext context, MoneyTransaction transaction) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        builder: (context) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              children: (_getPayActions(context).map((e) => ListTile(
                    leading: Icon(e.icon),
                    title: Text(e.label),
                    onTap: () {
                      Navigator.pop(context);
                      e.onClick();
                    },
                  ))).toList());
        });
  }

  Widget statusDisplayer() {
    if (transaction.status == null && transaction is! MoneyRecurrentRule) {
      throw Exception('Error');
    }

    final bool showRecurrencyStatus =
        (transaction is MoneyRecurrentRule) && widget.recurrentMode;

    final color = showRecurrencyStatus
        ? Theme.of(context).colorScheme.primary.lighten(0.2)
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
                Text(
                    showRecurrencyStatus
                        ? "Transacción recurrente"
                        : t.transaction.status
                            .tr_status(
                                status:
                                    transaction.status!.displayName(context))
                            .capitalize(),
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
                Text(showRecurrencyStatus
                    ? "El próximo pago de esta transacción recurrente esta previsto para el día ${DateFormat.yMMMMd().format(transaction.date)}. Puedes elegir si quieres saltar este pago o pagarlo eligiendo la fecha del pago"
                    : transaction.status!.description(context)),
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
                          onPressed: () => showPayModal(context, transaction),
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

    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(elevation: 0),
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
                        amountToConvert: transaction.value,
                        currency: transaction.account.currency,
                        textStyle: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        transaction.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!widget.recurrentMode)
                        Text(
                          DateFormat.yMMMMd().add_Hm().format(transaction.date),
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
                              (transaction as MoneyRecurrentRule)
                                  .recurrencyData
                                  .formText(context),
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Hero(
                    tag: 'transaction-icon-${transaction.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: transaction.color(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: transaction.isIncomeOrExpense
                          ? transaction.category!.icon.display(
                              color: transaction.color(context),
                              size: 42,
                            )
                          : const Icon(Icons.swap_vert, size: 42),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              if (transaction.status != null ||
                  transaction is MoneyRecurrentRule)
                statusDisplayer(),
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
                              Text(t.general.account),
                              Chip(
                                  label: Text(transaction.account.name),
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
                                    child: transaction.account.icon.display(
                                        color: Theme.of(context).primaryColor),
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
                              Text(transaction.isIncomeOrExpense
                                  ? t.general.category
                                  : t.transfer.form.to),
                              Chip(
                                  label: Text(transaction.isIncomeOrExpense
                                      ? transaction.category!.name
                                      : transaction.receivingAccount!.name),
                                  padding: const EdgeInsets.all(2),
                                  labelStyle: TextStyle(
                                      color:
                                          transaction.color(context).darken()),
                                  side: BorderSide(
                                      color:
                                          transaction.color(context).darken()),
                                  backgroundColor: transaction
                                      .color(context)
                                      .withOpacity(0.12),
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: transaction.isIncomeOrExpense
                                        ? transaction.category!.icon.display(
                                            color: transaction.color(context))
                                        : widget
                                            .transaction.receivingAccount!.icon
                                            .display(
                                                color:
                                                    transaction.color(context)),
                                  )),
                            ],
                          ),
                        ),
                        if (transaction.notes != null)
                          const Divider(indent: 12),
                        if (transaction.notes != null)
                          ListTile(
                            title: Text('Note'),
                            subtitle: Text(transaction.notes!),
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
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                                  )
                                ],
                              ))
                          .toList(),
                    ),
                    if (!widget.recurrentMode &&
                        (transaction is MoneyRecurrentRule))
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
