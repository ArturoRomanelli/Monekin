import 'package:collection/collection.dart';
import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/supported_currencies.dart';

class CurrencyService {
  List<Currency>? _currencies;

  List<Currency> getCurrencies() {
    if (_currencies != null) return _currencies!;

    _currencies = supportedCurrencies.map((e) => Currency.fromJson(e)).toList();

    return _currencies!;
  }

  List<Currency> searchCurrencies(String? toSearch, context) {
    if (toSearch == "" || toSearch == null) return getCurrencies();

    toSearch = toSearch.toLowerCase();

    return getCurrencies()
        .where((x) =>
            x.code.toLowerCase().contains(toSearch!) ||
            x.getLocaleName(context).toLowerCase().contains(toSearch))
        .toList();
  }

  Currency? getCurrencyByCode(String code) {
    return getCurrencies().firstWhereOrNull((element) => element.code == code);
  }

  Currency getUserDefaultCurrency() {
    return getCurrencyByCode("USD")!;
  }
}
