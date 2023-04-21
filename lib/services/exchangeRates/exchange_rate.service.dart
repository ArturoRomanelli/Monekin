import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/exchangeRates/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ExchangeRateService with ChangeNotifier {
  final _tableName = 'exchangeRates';

  // --- CLASS DEPENDENCIES ---
  ExchangeRateService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---

  /// Get the last exchange rates for all the currencies that the user have in the list of exchange rates
  Future<List<ExchangeRate>> getExchangeRates() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT date, currencyCode, exchangeRate FROM exchangeRates er '
        'WHERE date = ( '
        'SELECT MAX(date) '
        'FROM exchangeRates '
        'WHERE currencyCode = er.currencyCode) ORDER BY currencyCode');

    return [
      for (var i = 0; i < maps.length; i++) await ExchangeRate.fromDB(maps[i])
    ];
  }

  /// Get all the exchange rates that a currency have in the app
  Future<List<ExchangeRate>> getExchangeRatesOf(String currencyCode) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        orderBy: 'date DESC',
        where: 'currencyCode = ?',
        whereArgs: [currencyCode]);

    return [
      for (var i = 0; i < maps.length; i++) await ExchangeRate.fromDB(maps[i])
    ];
  }

  /// Get the last exchange rate before a specified date, for a given currency. If the date is not provided, the current date is used
  Future<ExchangeRate?> getLastExchangeRateOf(
      {required String currencyCode, DateTime? date}) async {
    date ??= DateTime.now();

    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        limit: 1,
        orderBy: 'date DESC',
        where: 'currencyCode = ? AND date <= ?',
        whereArgs: [currencyCode, date.toIso8601String()]);

    return maps.isEmpty ? null : ExchangeRate.fromDB(maps.first);
  }

  Future<void> insertOrUpdateExchangeRate(ExchangeRate toInsert) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      toInsert.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<void> deleteExchangeRates({String? currencyCode}) async {
    final db = await _dbService!.database;

    await db.delete(
      _tableName,
      where: currencyCode != null ? 'currencyCode = ?' : null,
      whereArgs: [if (currencyCode != null) currencyCode],
    );

    notifyListeners();
  }

  Future<double> convertValueToCurrency(double value,
      {required Currency toCurrency,
      Currency? fromCurrency,
      DateTime? exchangeRateDate}) async {
    final double exchangeRateTo = (await getLastExchangeRateOf(
                currencyCode: toCurrency.code, date: exchangeRateDate))
            ?.exchangeRate ??
        1;

    double exchangeRateFrom = 1;

    if (fromCurrency != null) {
      exchangeRateFrom = (await getLastExchangeRateOf(
                  currencyCode: fromCurrency.code, date: exchangeRateDate))
              ?.exchangeRate ??
          1;
    }

    return value * exchangeRateTo / exchangeRateFrom;
  }
}
