import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:drift/drift.dart';

class CurrencyService {
  final _currencyTableName = 'currencies';
  final _currencyNamesTableName = 'currencyNames';

  String get _baseQuery =>
      'SELECT currency.code, currency.symbol, names.es as name FROM $_currencyTableName as currency'
      ' JOIN $_currencyNamesTableName as names ON currency.code = names.currencyCode';

  final DatabaseImpl db;

  CurrencyService._(this.db);
  static final CurrencyService instance =
      CurrencyService._(DatabaseImpl.instance);

  Future<int> insertCurrency(CurrencyInDB currency) {
    return db.into(db.currencies).insert(currency);
  }

  Future<int> deleteCurrency(String currencyId) {
    return (db.delete(db.categories)..where((tbl) => tbl.id.equals(currencyId)))
        .go();
  }

  Stream<List<Currency>?> getCurrencies() {
    return (db.customSelect(_baseQuery,
            readsFrom: {db.currencies, db.currencyNames}))
        .map((e) => Currency(
            name: e.data['name'],
            code: e.data['code'],
            symbol: e.data['symbol']))
        .watch();
  }

  Stream<Currency?> getCurrencyByCode(String code) {
    return (db.customSelect('$_baseQuery WHERE currency.code = ? LIMIT 1',
            variables: [Variable.withString(code)],
            readsFrom: {db.currencies, db.currencyNames}))
        .map((e) => Currency(
            name: e.data['name'],
            code: e.data['code'],
            symbol: e.data['symbol']))
        .watchSingleOrNull();
  }

  Stream<List<Currency>?> searchCurrencies(String? toSearch) {
    if (toSearch == null || toSearch.trim() == '') return getCurrencies();

    toSearch = '%${toSearch.trim()}%';

    return (db.customSelect(
            '$_baseQuery WHERE currency.code LIKE ? OR names.es LIKE ?',
            readsFrom: {db.currencies, db.currencyNames}))
        .map((e) => Currency(
            name: e.data['name'],
            code: e.data['code'],
            symbol: e.data['symbol']))
        .watch();
  }

  Future<Currency> getUserPreferredCurrency() async {
    final settingService = UserSettingService.instance;

    String? currencyCode =
        await (settingService.getSetting(SettingKey.preferredCurrency)).first;

    if (currencyCode == null) {
      currencyCode = 'USD';

      await settingService.setSetting(
          SettingKey.preferredCurrency, currencyCode);
    }

    return (await getCurrencyByCode(currencyCode).first)!;
  }
}
