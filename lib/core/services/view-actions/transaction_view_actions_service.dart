import 'package:monekin/app/transactions/form/transaction_form.page.dart';
import 'package:monekin/core/database/app_db.dart';
import 'package:monekin/core/database/services/transaction/transaction_service.dart';
import 'package:monekin/core/models/transaction/transaction.dart';
import 'package:monekin/core/utils/list_tile_action_item.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../i18n/translations.g.dart';

class TransactionViewActionService {
  final TransactionService transactionService = TransactionService.instance;

  TransactionViewActionService();

  List<ListTileActionItem> transactionDetailsActions(BuildContext context,
      {required MoneyTransaction transaction, Widget? prevPage}) {
    final isRecurrent = transaction.recurrentInfo.isRecurrent;

    return [
      ListTileActionItem(
          label: t.general.edit,
          icon: Icons.edit,
          onClick: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionFormPage(
                        prevPage: prevPage,
                        transactionToEdit: transaction,
                        mode: transaction.isIncomeOrExpense
                            ? TransactionFormMode.incomeOrExpense
                            : TransactionFormMode.transfer,
                      )))),
      if (transaction.recurrentInfo.isNoRecurrent)
        ListTileActionItem(
            label: t.transaction.duplicate_short,
            icon: Icons.control_point_duplicate,
            onClick: () => TransactionViewActionService()
                .cloneTransactionWithAlertAndSnackBar(context,
                    transaction: transaction, returnPage: prevPage)),
      ListTileActionItem(
          label: t.general.delete,
          icon: Icons.delete,
          onClick: () => TransactionViewActionService()
              .deleteTransactionWithAlertAndSnackBar(context,
                  transactionId: transaction.id,
                  returnPage: prevPage,
                  isRecurrent: isRecurrent))
    ];
  }

  deleteTransactionWithAlertAndSnackBar(BuildContext context,
      {required String transactionId,
      Widget? returnPage,
      bool isRecurrent = false}) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(!isRecurrent
              ? t.transaction.delete
              : t.recurrent_transactions.details.delete_header),
          content: SingleChildScrollView(
            child: Text(!isRecurrent
                ? t.transaction.delete_warning_message
                : t.recurrent_transactions.details.delete_message),
          ),
          actions: [
            TextButton(
              child: Text(t.general.continue_text),
              onPressed: () {
                transactionService
                    .deleteTransaction(transactionId)
                    .then((value) {
                  if (value == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error removing the transaction')),
                    );

                    return;
                  }

                  if (returnPage != null) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => returnPage));
                  } else {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(t.transaction.delete_success),
                  ));
                }).catchError((err) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$err')));
                });
              },
            ),
          ],
        );
      },
    );
  }

  cloneTransactionWithAlertAndSnackBar(BuildContext context,
      {required MoneyTransaction transaction, Widget? returnPage}) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.transaction.duplicate),
          content: SingleChildScrollView(
              child: Text(t.transaction.duplicate_warning_message)),
          actions: [
            TextButton(
              child: Text(t.general.continue_text),
              onPressed: () {
                transactionService
                    .insertTransaction(TransactionInDB(
                        id: const Uuid().v4(),
                        accountID: transaction.accountID,
                        date: transaction.date,
                        value: transaction.value,
                        isHidden: transaction.isHidden,
                        categoryID: transaction.categoryID,
                        notes: transaction.notes,
                        title: transaction.title,
                        receivingAccountID: transaction.receivingAccountID,
                        status: transaction.status,
                        valueInDestiny: transaction.valueInDestiny))
                    .then((value) {
                  if (returnPage != null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => returnPage),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(t.transaction.duplicate_success),
                  ));
                }).catchError((err) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$err')));
                });
              },
            ),
          ],
        );
      },
    );
  }
}
