import 'package:finlytics/core/database/db.service.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:finlytics/services/user-settings/user_settings.service.dart';

class CurrencyService {
  final _currencyTableName = 'currencies';
  final _currencyNamesTableName = 'currencyNames';

  String get _baseQuery =>
      'SELECT currency.code, currency.symbol, names.es as name FROM $_currencyTableName as currency'
      ' JOIN $_currencyNamesTableName as names ON currency.code = names.currencyCode';

  // --- CLASS DEPENDENCIES ---
  CurrencyService(this._dbService);
  final DbService? _dbService;

  Future<List<Currency>> getCurrencies() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(_baseQuery);

    return [
      for (var i = 0; i < maps.length; i++) await Currency.fromDB(maps[i])
    ];
  }

  Future<List<Currency>> searchCurrencies(String? toSearch) async {
    if (toSearch == null) return await getCurrencies();

    toSearch = '%${toSearch.trim()}%';

    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('$_baseQuery WHERE currency.code LIKE ?', [toSearch]);

    return [
      for (var i = 0; i < maps.length; i++) await Currency.fromDB(maps[i])
    ];
  }

  Future<Currency?> getCurrencyByCode(String code) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('$_baseQuery WHERE currency.code = ?', [code]);

    return maps.isEmpty ? null : Currency.fromDB(maps.first);
  }

  Future<Currency> getUserPreferredCurrency() async {
    final settingService = UserSettingsService(_dbService);

    String? currencyCode =
        await settingService.getSetting(SettingKey.preferredCurrency);

    if (currencyCode == null) {
      currencyCode = 'USD';

      await settingService.setSetting(
          SettingKey.preferredCurrency, currencyCode);
    }

    return (await getCurrencyByCode(currencyCode))!;
  }
}
