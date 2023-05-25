import 'package:finlytics/app/transactions/transaction_form.page.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

class TransactionUIActionService {
  final TransactionService transactionService = TransactionService.instance;

  TransactionUIActionService();

  List<TransactionDetailAction> transactionDetailsActions(BuildContext context,
      {required MoneyTransaction transaction, Widget? prevPage}) {
    return [
      TransactionDetailAction(
          label: 'Edit',
          icon: Icons.edit,
          onClick: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionFormPage(
                        prevPage: prevPage,
                        transactionToEdit: transaction,
                      )))),
      TransactionDetailAction(
          label: 'Clone',
          icon: Icons.control_point_duplicate,
          onClick: () => TransactionUIActionService()
              .cloneTransactionWithAlertAndSnackBar(context,
                  transaction: transaction, returnPage: prevPage)),
      TransactionDetailAction(
          label: 'Delete',
          icon: Icons.delete,
          onClick: () => TransactionUIActionService()
              .deleteTransactionWithAlertAndSnackBar(context,
                  transactionId: transaction.id, returnPage: prevPage))
    ];
  }

  deleteTransactionWithAlertAndSnackBar(BuildContext context,
      {required String transactionId, Widget? returnPage}) {
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
                  if (returnPage != null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => returnPage),
                        (Route<dynamic> route) => false);
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
                        note: transaction.note,
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
