import 'package:finlytics/app/accounts/account_form.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/utils/list_tile_action_item.dart';
import 'package:flutter/material.dart';

class AccountViewActionService {
  final AccountService accountService = AccountService.instance;

  AccountViewActionService();

  List<ListTileActionItem> accountDetailsActions(BuildContext context,
      {required Account account, Widget? prevPage}) {
    return [
      ListTileActionItem(
          label: 'Edit',
          icon: Icons.edit,
          onClick: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountFormPage(
                        prevPage: prevPage,
                        account: account,
                      )))),
      ListTileActionItem(
          label: 'Delete',
          icon: Icons.delete,
          onClick: () => AccountViewActionService()
              .deleteTransactionWithAlertAndSnackBar(context,
                  transactionId: account.id, returnPage: prevPage))
    ];
  }

  deleteTransactionWithAlertAndSnackBar(BuildContext context,
      {required String transactionId, Widget? returnPage}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar cuenta'),
          content: const SingleChildScrollView(
              child: Text('Esta acción es irreversible, ¿deseas continuar?')),
          actions: [
            TextButton(
              child: const Text('Yes, continue'),
              onPressed: () {
                accountService.deleteAccount(transactionId).then((value) {
                  if (returnPage != null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => returnPage),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Cuenta borrada con exito')));
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
