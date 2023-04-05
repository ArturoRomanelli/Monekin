// ignore_for_file: constant_identifier_names

import 'package:finlytics/services/locale_names.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Currency {
  final String code;

  final LocaleNames _names;

  String get currencyIconPath =>
      'lib/assets/icons/currency_flags/${code.toLowerCase()}.svg';

  Currency({required this.code, required LocaleNames names}) : _names = names;

  /// Get the currency name in the language of the user
  String getLocaleName(context) {
    return _names.toJson()[
            AppLocalizations.of(context)!.localeName.split("_").first] ??
        _names.en;
  }

  factory Currency.fromJson(Map<String, dynamic> json) =>
      Currency(code: json["code"], names: LocaleNames.fromJson(json["names"]));

  Map<String, dynamic> toJson() => {"code": code, "names": _names.toJson()};
}
