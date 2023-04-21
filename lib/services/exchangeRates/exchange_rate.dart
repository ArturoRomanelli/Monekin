import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:intl/intl.dart';

class ExchangeRate {
  Currency currency;

  DateTime date;

  double exchangeRate;

  ExchangeRate(
      {required this.currency, required this.date, required this.exchangeRate});

  /// Convert this entity to the format that it has in the database. This is usually a plain object, without nested data/objects.
  Map<String, dynamic> toDB() => {
        'currencyCode': currency.code,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'exchangeRate': exchangeRate
      };

  /// Convert a row of this entity in the database to this class
  static Future<ExchangeRate> fromDB(Map<String, dynamic> data) async =>
      ExchangeRate(
          currency: (await CurrencyService(DbService.instance)
              .getCurrencyByCode(data['currencyCode']))!,
          date: DateTime.parse(data['date']),
          exchangeRate: data['exchangeRate']);
}
