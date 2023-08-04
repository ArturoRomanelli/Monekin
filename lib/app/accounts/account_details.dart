import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:monekin/core/database/services/account/account_service.dart';
import 'package:monekin/core/models/account/account.dart';
import 'package:monekin/core/presentation/widgets/card_with_header.dart';
import 'package:monekin/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:monekin/core/services/view-actions/account_view_actions_service.dart';
import 'package:monekin/i18n/translations.g.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key, required this.account});

  final Account account;

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  ListTile buildCopyableTile(String title, String value) {
    final snackbarDisplayer = ScaffoldMessenger.of(context).showSnackBar;

    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value)).then((_) {
              snackbarDisplayer(
                SnackBar(content: Text(t.general.clipboard.success(x: title))),
              );
            }).catchError((_) {
              snackbarDisplayer(
                SnackBar(content: Text(t.general.clipboard.error)),
              );
            });
          },
          icon: const Icon(Icons.copy_rounded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountDetailsActions =
        AccountViewActionService().accountDetailsActions(
      context,
      account: widget.account,
      navigateBackOnDelete: true,
    );

    final t = Translations.of(context);

    return StreamBuilder(
        stream: AccountService.instance.getAccountById(widget.account.id),
        initialData: widget.account,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(elevation: 0),
            body: Builder(builder: (context) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              final account = snapshot.data!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(account.name),
                            StreamBuilder(
                                initialData: 0.0,
                                stream: AccountService.instance
                                    .getAccountMoney(account: account),
                                builder: (context, snapshot) {
                                  return CurrencyDisplayer(
                                    amountToConvert: snapshot.data!,
                                    currency: account.currency,
                                    textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600),
                                  );
                                }),
                          ],
                        ),
                        Hero(
                          tag: 'account-icon-${widget.account.id}',
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                                border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            child: account.icon.displayFilled(
                              size: 36,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CardWithHeader(
                              title: 'Info',
                              body: Column(
                                children: [
                                  ListTile(
                                    title: Text(t.account.date),
                                    subtitle: Text(
                                      DateFormat.yMMMMEEEEd()
                                          .add_Hm()
                                          .format(account.date),
                                    ),
                                  ),
                                  const Divider(indent: 12),
                                  ListTile(
                                    title: Text(t.account.types.title),
                                    subtitle: Text(account.type.title(context)),
                                  ),
                                  if (account.description != null) ...[
                                    const Divider(indent: 12),
                                    ListTile(
                                      title: Text(t.account.form.notes),
                                      subtitle: Text(account.description!),
                                    ),
                                  ],
                                  if (account.iban != null) ...[
                                    const Divider(indent: 12),
                                    buildCopyableTile(
                                        t.account.form.iban, account.iban!)
                                  ],
                                  if (account.swift != null) ...[
                                    const Divider(indent: 12),
                                    buildCopyableTile(
                                        t.account.form.swift, account.swift!)
                                  ]
                                ],
                              )),
                          const SizedBox(height: 16),
                          CardWithHeader(
                            title: t.general.quick_actions,
                            body: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Wrap(
                                    spacing: 24,
                                    runSpacing: 16,
                                    children: accountDetailsActions
                                        .map((item) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton.filledTonal(
                                                    onPressed: item.onClick,
                                                    icon: Icon(
                                                      item.icon,
                                                      size: 32,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    )),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.label,
                                                  softWrap: false,
                                                  overflow: TextOverflow.fade,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                )
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          );
        });
  }
}
