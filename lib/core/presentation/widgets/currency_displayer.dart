import 'dart:math';

import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';

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
    final String decimalSep = numberFormatSymbols['en']?.DECIMAL_SEP;
    final valueFontSize = widget.textStyle.fontSize ?? 16;

    return Builder(builder: (context) {
      if (currency == null) {
        return Skeleton(width: 50, height: valueFontSize);
      }

      // Remove the decimal separator from the symbol, otherwise the parts won't be splitted correctly
      final String symbolWithoutDecSep =
          currency!.symbol.replaceAll(decimalSep, '');

      final String formattedAmount =
          NumberFormat.currency(decimalDigits: 2, symbol: symbolWithoutDecSep)
              .format(widget.amountToConvert);

      // Get the decimal and the integer part, and restore the original symbol
      final List<String> parts = formattedAmount
          .split(decimalSep)
          .map((e) => e.replaceAll(symbolWithoutDecSep, currency!.symbol))
          .toList();

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(parts[0], style: widget.textStyle),
          if (widget.showDecimals) Text(decimalSep, style: widget.textStyle),
          if (widget.showDecimals)
            Text(parts[1],
                style: widget.textStyle.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: max(valueFontSize * 0.75, 14),
                ))
        ],
      );
    });
  }
}
