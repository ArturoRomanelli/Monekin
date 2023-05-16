import 'package:finlytics/core/database/database_impl.dart';

class ExchangeRate extends ExchangeRateInDB {
  CurrencyInDB currency;

  ExchangeRate(
      {required super.date,
      required this.currency,
      required super.exchangeRate})
      : super(currencyCode: currency.code);
}
