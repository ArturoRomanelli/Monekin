import 'package:finlytics/core/models/exchange-rate/exchange_rate.dart';
import 'package:drift/drift.dart';

import '../../database_impl.dart';

class ExchangeRateService {
  final DatabaseImpl db;

  ExchangeRateService._(this.db);
  static final ExchangeRateService instance =
      ExchangeRateService._(DatabaseImpl.instance);

  Future<int> insertOrUpdateExchangeRate(ExchangeRateInDB toInsert) {
    return db
        .into(db.exchangeRates)
        .insert(toInsert, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteExchangeRates({String? currencyCode}) {
    return (db.delete(db.exchangeRates)
          ..where((e) => currencyCode != null
              ? e.currencyCode.equals(currencyCode)
              : e.currencyCode.isNotNull()))
        .go();
  }

  /// Get the last exchange rates for all the currencies that the user have in the list of exchange rates
  getExchangeRates({double? limit}) {
    limit ??= -1;

    return db.getLastExchangeRates(limit: limit);
  }

  /// Get all the exchange rates that a currency have in the app
  Stream<List<ExchangeRate>> getExchangeRatesOf(String currencyCode,
      {double? limit}) {
    limit ??= -1;

    return db
        .getExchangeRates(
            predicate: (e, currency) => e.currencyCode.equals(currencyCode),
            limit: limit)
        .watch();
  }

  /// Get the last exchange rate before a specified date, for a given currency. If the date is not provided, the current date is used
  getLastExchangeRateOf({required String currencyCode, DateTime? date}) {
    date ??= DateTime.now();

    return db
        .getExchangeRates(
            predicate: (e, currency) =>
                e.currencyCode.equals(currencyCode) &
                e.date.isSmallerOrEqualValue(date!),
            limit: 1)
        .watch();
  }
}
