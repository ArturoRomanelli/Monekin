import 'package:finlytics/app/currencies/exchange_rate_form.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:finlytics/core/models/exchangeRate/exchange_rate.dart';
import 'package:finlytics/services/exchangeRates/exchange_rate.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExchangeRateDetailsPage extends StatefulWidget {
  const ExchangeRateDetailsPage({super.key, required this.currency});

  final Currency currency;

  @override
  State<ExchangeRateDetailsPage> createState() =>
      _ExchangeRateDetailsPageState();
}

class _ExchangeRateDetailsPageState extends State<ExchangeRateDetailsPage> {
  List<ExchangeRate>? exchangeRates;

  @override
  void initState() {
    super.initState();

    getExchangeRates();
  }

  getExchangeRates() {
    context
        .read<ExchangeRateService>()
        .getExchangeRatesOf(widget.currency.code)
        .then((value) {
      setState(() {
        exchangeRates = value;
      });
    });
  }

  deleteAllRates() {
    context
        .read<ExchangeRateService>()
        .deleteExchangeRates(currencyCode: widget.currency.code)
        .then((value) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipos de cambio borrados con exito')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipo de cambio'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete),
                      minLeadingWidth: 26,
                      title: Text('Delete'),
                    ))
              ];
            },
            onSelected: (String value) {
              if (value == 'delete') deleteAllRates();
            },
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 6),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: widget.currency.displayFlagIcon(size: 50),
              ),
              const SizedBox(width: 22),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currency.name,
                    style: TextStyle(
                        fontSize: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .fontSize),
                  ),
                  Text(widget.currency.code),
                ],
              )
            ],
          ),
        ),
        const Divider(height: 10),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text("Histórico de tasas"),
        ),
        if (exchangeRates != null)
          SingleChildScrollView(
              child: ListView.separated(
            shrinkWrap: true,
            itemCount: exchangeRates!.length,
            itemBuilder: (context, index) {
              final item = exchangeRates![index];

              return ListTile(
                title: Text(DateFormat.yMMMMd().format(item.date)),
                trailing: Text(
                    NumberFormat.currency(symbol: '', decimalDigits: 4)
                        .format(item.exchangeRate)),
                onTap: () async {
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ExchangeRateFormDialog(
                          preSelectedCurrency: widget.currency,
                          preSelectedDate: item.date,
                          preSelectedRate: item.exchangeRate,
                        );
                      });

                  getExchangeRates();
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          ))
      ]),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.all(4),
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return ExchangeRateFormDialog(
                      preSelectedCurrency: widget.currency,
                    );
                  });

              getExchangeRates();
            },
            icon: const Icon(Icons.add),
            label: const Text('Añadir tipo de cambio'),
          ),
        )
      ],
    );
  }
}
