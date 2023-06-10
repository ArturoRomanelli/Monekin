import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/services/view-actions/account_view_actions_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key, required this.account, this.prevPage});

  final Account account;

  final Widget? prevPage;

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final transactionDetailsActions = AccountViewActionService()
        .accountDetailsActions(context,
            account: widget.account, prevPage: widget.prevPage);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
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
            const SizedBox(height: 24),
            SingleChildScrollView(
              child: Column(
                children: [
                  CardWithHeader(
                      title: 'Data',
                      body: Column(
                        children: [
                          ListTile(
                            title: Text("Fecha de creacion"),
                            subtitle: Text(
                              DateFormat.yMMMMEEEEd()
                                  .add_Hm()
                                  .format(widget.account.date),
                            ),
                          ),
                          const Divider(indent: 12),
                          ListTile(
                            title: Text("Tipo de cuenta"),
                            subtitle: Text(widget.account.type.title(context)),
                          ),
                          if (widget.account.description != null)
                            const Divider(indent: 12),
                          if (widget.account.description != null)
                            ListTile(
                              title: Text("Descripción / Notas"),
                              subtitle: Text(widget.account.description!),
                            )
                        ],
                      )),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: 'Acciones rápidas',
                    body: GridView.count(
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
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
