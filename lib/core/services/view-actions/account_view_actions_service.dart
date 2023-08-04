import 'package:flutter/material.dart';
import 'package:monekin/app/accounts/account_form.dart';
import 'package:monekin/app/transactions/form/transaction_form.page.dart';
import 'package:monekin/core/database/services/account/account_service.dart';
import 'package:monekin/core/models/account/account.dart';
import 'package:monekin/core/utils/list_tile_action_item.dart';
import 'package:monekin/i18n/translations.g.dart';

class AccountViewActionService {
  final AccountService accountService = AccountService.instance;

  AccountViewActionService();

  List<ListTileActionItem> accountDetailsActions(BuildContext context,
      {required Account account, bool navigateBackOnDelete = false}) {
    final t = Translations.of(context);

    return [
      ListTileActionItem(
          label: t.general.edit,
          icon: Icons.edit,
          onClick: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountFormPage(
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
          onClick: () =>
              AccountViewActionService().deleteTransactionWithAlertAndSnackBar(
                context,
                transactionId: account.id,
                navigateBack: navigateBackOnDelete,
              ))
    ];
  }

  deleteTransactionWithAlertAndSnackBar(BuildContext context,
      {required String transactionId, required bool navigateBack}) {
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
                  Navigator.pop(context);

                  if (navigateBack) {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.account.delete.success)));
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
