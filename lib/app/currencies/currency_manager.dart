import 'package:finlytics/app/currencies/exchange_rate_details.dart';
import 'package:finlytics/app/currencies/exchange_rate_form.dart';
import 'package:finlytics/core/presentation/widgets/currency_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:finlytics/core/database/services/currency/currency.service.dart';
import 'package:finlytics/core/models/exchangeRate/exchange_rate.dart';
import 'package:finlytics/core/database/services/exchangeRates/exchange_rate.service.dart';
import 'package:finlytics/core/database/services/user-settings/user_settings.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/presentation/widgets/empty_indicator.dart';

class CurrencyManagerPage extends StatefulWidget {
  const CurrencyManagerPage({super.key});

  @override
  State<CurrencyManagerPage> createState() => _CurrencyManagerPageState();
}

class _CurrencyManagerPageState extends State<CurrencyManagerPage> {
  Currency? _userCurrency;

  List<ExchangeRate>? exchangeRates;

  @override
  void initState() {
    super.initState();

    context.read<CurrencyService>().getUserPreferredCurrency().then((value) {
      setState(() {
        _userCurrency = value;
      });
    });

    getExchangeRates();
  }

  getExchangeRates() {
    context.read<ExchangeRateService>().getExchangeRates().then((value) {
      setState(() {
        exchangeRates = value;
      });
    });
  }

  changePreferredCurrency(Currency newCurrency) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change the base currency'),
          content: const SingleChildScrollView(
              child: Text(
                  'All the saved exchange rates will be deleted if you perform this action')),
          actions: [
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                context
                    .read<UserSettingsService>()
                    .setSetting(SettingKey.preferredCurrency, newCurrency.code)
                    .then(
                  (value) {
                    setState(() {
                      _userCurrency = newCurrency;
                    });

                    context
                        .read<ExchangeRateService>()
                        .deleteExchangeRates()
                        .then((value) {
                      getExchangeRates();
                    });
                  },
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency manager'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            minVerticalPadding: 8,
            leading: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: _userCurrency != null
                  ? _userCurrency!.displayFlagIcon(size: 42)
                  : const Skeleton(height: 42, width: 42),
            ),
            title: Text('Divisa base'),
            subtitle: _userCurrency != null
                ? Text(_userCurrency!.name)
                : const Skeleton(height: 12, width: 50),
            onTap: () {
              if (_userCurrency == null) return;

              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return CurrencySelectorModal(
                        preselectedCurrency: _userCurrency!,
                        onCurrencySelected: (newCurrency) async {
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          changePreferredCurrency(newCurrency);
                        });
                  });
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tipos de cambio'),
                TextButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const ExchangeRateFormDialog();
                          });

                      getExchangeRates();
                    },
                    child: Text('Añadir'))
              ],
            ),
          ),
          if (exchangeRates != null && exchangeRates!.isNotEmpty)
            SingleChildScrollView(
              child: ListView.separated(
                itemCount: exchangeRates!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = exchangeRates![index];

                  return ListTile(
                    minVerticalPadding: 8,
                    leading: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: item.currency.displayFlagIcon(size: 42),
                    ),
                    title: Text(item.currency.code),
                    subtitle: Text(item.currency.name),
                    trailing: Text(item.exchangeRate.toString()),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExchangeRateDetailsPage(
                                    currency: item.currency,
                                  ))).whenComplete(() => getExchangeRates());
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(indent: 68);
                },
              ),
            ),
          if (exchangeRates != null && exchangeRates!.isEmpty)
            Expanded(
                child: EmptyIndicator(
                    title: 'No hay registros',
                    description:
                        'Añade tipos de cambio aqui para que en caso de tener cuentas en otras divisas distintas a tu divisa base nuestros gráficos sean mas exactos'))
        ],
      ),
    );
  }
}
