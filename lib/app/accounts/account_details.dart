import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/card_with_header.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/services/view-actions/account_view_actions_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key, required this.account, this.prevPage});

  final Account account;

  final Widget? prevPage;

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
    final transactionDetailsActions = AccountViewActionService()
        .accountDetailsActions(context,
            account: widget.account, prevPage: widget.prevPage);

    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
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
                    Text(widget.account.name),
                    StreamBuilder(
                        initialData: 0.0,
                        stream: AccountService.instance
                            .getAccountMoney(account: widget.account),
                        builder: (context, snapshot) {
                          return CurrencyDisplayer(
                            amountToConvert: snapshot.data!,
                            currency: widget.account.currency,
                            textStyle: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w600),
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
                            width: 2, color: Theme.of(context).primaryColor)),
                    child: widget.account.icon.displayFilled(
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
                                  .format(widget.account.date),
                            ),
                          ),
                          const Divider(indent: 12),
                          ListTile(
                            title: Text(t.account.types.title),
                            subtitle: Text(widget.account.type.title(context)),
                          ),
                          if (widget.account.description != null) ...[
                            const Divider(indent: 12),
                            ListTile(
                              title: Text(t.account.form.notes),
                              subtitle: Text(widget.account.description!),
                            ),
                          ],
                          if (widget.account.iban != null) ...[
                            const Divider(indent: 12),
                            buildCopyableTile(
                                t.account.form.iban, widget.account.iban!)
                          ],
                          if (widget.account.swift != null) ...[
                            const Divider(indent: 12),
                            buildCopyableTile(
                                t.account.form.swift, widget.account.swift!)
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
                            children: transactionDetailsActions
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
                                              fontWeight: FontWeight.w300),
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
      ),
    );
  }
}
