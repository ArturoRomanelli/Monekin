import 'package:flutter_svg/flutter_svg.dart';

class Currency {
  final String code;
  final String symbol;

  final String name;

  String get currencyIconPath =>
      'assets/icons/currency_flags/${code.toLowerCase()}.svg';

  SvgPicture displayFlagIcon({double? size}) {
    return SvgPicture.asset(
      currencyIconPath,
      height: size,
      width: size,
    );
  }

  Currency({required this.code, required this.symbol, required this.name});

  /// Convert a row of this entity in the database to this class
  static Future<Currency> fromDB(Map<String, dynamic> data) async =>
      Currency(code: data['code'], symbol: data['symbol'], name: data['name']);
}
