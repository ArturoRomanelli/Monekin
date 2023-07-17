import 'package:finlytics/app/transactions/transaction_form.page.dart';
import 'package:finlytics/core/database/app_db.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/utils/list_tile_action_item.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionViewActionService {
  final TransactionService transactionService = TransactionService.instance;

  TransactionViewActionService();

  List<ListTileActionItem> transactionDetailsActions(BuildContext context,
      {required MoneyTransaction transaction, Widget? prevPage}) {
    final isRecurrent = transaction.recurrentInfo.isRecurrent;

    return [
      ListTileActionItem(
          label: 'Edit',
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
            label: 'Clone',
            icon: Icons.control_point_duplicate,
            onClick: () => TransactionViewActionService()
                .cloneTransactionWithAlertAndSnackBar(context,
                    transaction: transaction, returnPage: prevPage)),
      ListTileActionItem(
          label: 'Delete',
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar transacción'),
          content: const SingleChildScrollView(
              child: Text('Esta acción es irreversible, ¿deseas continuar?')),
          actions: [
            TextButton(
              child: const Text('Yes, continue'),
              onPressed: () {
                transactionService
                    .deleteTransaction(transactionId)
                    .then((value) {
                  if (value == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('No se ha podido eliminar el registro')),
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

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Transacción borrada con exito')));
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clonar transacción'),
          content: const SingleChildScrollView(
              child: Text(
                  'Se creará una transacción identica a esta con su misma fecha, ¿deseas continuar?')),
          actions: [
            TextButton(
              child: const Text('Yes, continue'),
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

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Transacción clonada con exito')));
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
