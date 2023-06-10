import 'package:finlytics/app/accounts/account_form.dart';
import 'package:finlytics/app/transactions/transaction_form.page.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/utils/list_tile_action_item.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class AccountViewActionService {
  final AccountService accountService = AccountService.instance;

  AccountViewActionService();

  List<ListTileActionItem> accountDetailsActions(BuildContext context,
      {required Account account, Widget? prevPage}) {
    final t = Translations.of(context);

    return [
      ListTileActionItem(
          label: t.general.edit,
          icon: Icons.edit,
          onClick: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountFormPage(
                        prevPage: prevPage,
                        account: account,
                      )))),
      ListTileActionItem(
          label: t.transfer.create,
          icon: Icons.swap_vert_rounded,
          onClick: () async {
            showAccountsWarn() => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(t.transfer.need_two_accounts_warning_header),
                      content: SingleChildScrollView(
                          child: Text(
                              t.transfer.need_two_accounts_warning_message)),
                      actions: [
                        TextButton(
                            child: Text(t.general.understood),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    );
                  },
                );

            navigateToTransferForm() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionFormPage(
                          prevPage: prevPage,
                          fromAccount: account,
                          mode: TransactionFormMode.transfer,
                        )));

            final numberOfAccounts =
                (await AccountService.instance.getAccounts().first).length;

            if (numberOfAccounts <= 1) {
              await showAccountsWarn();
            } else {
              await navigateToTransferForm();
            }
          }),
      ListTileActionItem(
          label: t.general.delete,
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
          title: Text(t.account.delete.warning_header),
          content:
              SingleChildScrollView(child: Text(t.account.delete.warning_text)),
          actions: [
            TextButton(
              child: Text(t.general.confirm),
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
