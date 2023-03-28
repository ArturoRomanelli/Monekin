import 'package:collection/collection.dart';
import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/supported_currencies.dart';

class CurrencyService {
  List<Currency>? _currencies;

  List<Currency> getCurrencies() {
    if (_currencies != null) return _currencies!;

    return supportedCurrencies.map((e) => Currency.fromJson(e)).toList();
  }

  List<Currency> searchCurrencies(String? toSearch, context) {
    if (toSearch == "" || toSearch == null) return getCurrencies();

    return getCurrencies()
        .where((x) =>
            x.code.contains(toSearch) ||
            x.getLocaleName(context).contains(toSearch))
        .toList();
  }

  Currency? getCurrencyByCode(String code) {
    return getCurrencies().firstWhereOrNull((element) => element.code == code);
  }

  Currency getUserDefaultCurrency() {
    return getCurrencyByCode("USD")!;
  }
}
