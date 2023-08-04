import 'package:flutter/material.dart';
import 'package:monekin/core/database/app_db.dart';
import 'package:monekin/core/database/services/currency/currency_service.dart';
import 'package:monekin/core/presentation/widgets/skeleton.dart';

import 'ui_number_formatter.dart';

class CurrencyDisplayer extends StatefulWidget {
  /// Creates a widget that takes an amount and display it in a localized currency format with the decimals smaller that the rest of the text. This widget is not in charge of the conversion to any currency, that is, the amount will be remain as it is.
  const CurrencyDisplayer(
      {super.key,
      required this.amountToConvert,
      this.currency,
      this.showDecimals = true,
      this.textStyle = const TextStyle(inherit: true)});

  final double amountToConvert;

  /// The currency of the amount, used to display the symbol. If not specified, will be the user preferred currency
  final CurrencyInDB? currency;

  final TextStyle textStyle;

  final bool showDecimals;

  @override
  State<CurrencyDisplayer> createState() => _CurrencyDisplayerState();
}

class _CurrencyDisplayerState extends State<CurrencyDisplayer> {
  CurrencyInDB? currency;

  @override
  void initState() {
    super.initState();

    currency = widget.currency;

    if (currency == null) {
      CurrencyService.instance.getUserPreferredCurrency().then((curr) {
        if (mounted) {
          setState(() {
            currency = curr;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueFontSize = widget.textStyle.fontSize ?? 16;

    if (widget.currency != null) {
      return UINumberFormatter(
        UINumberFormatterMode.currency,
        amountToConvert: widget.amountToConvert,
        currency: widget.currency,
        showDecimals: widget.showDecimals,
        textStyle: widget.textStyle,
      ).getTextWidget();
    }

    return FutureBuilder(
        future: CurrencyService.instance.getUserPreferredCurrency(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Skeleton(width: 50, height: valueFontSize);
          }

          return UINumberFormatter(
            UINumberFormatterMode.currency,
            amountToConvert: widget.amountToConvert,
            currency: CurrencyInDB(
                code: snapshot.data!.code, symbol: snapshot.data!.symbol),
            showDecimals: widget.showDecimals,
            textStyle: widget.textStyle,
          ).getTextWidget();
        });
  }
}
