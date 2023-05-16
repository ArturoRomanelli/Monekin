import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';

class Account extends AccountInDB {
  Account(
      {required super.id,
      required super.name,
      required super.iniValue,
      required super.date,
      required super.type,
      required super.iconId,
      required this.currency,
      super.description,
      super.iban,
      super.swift})
      : super(currencyId: currency.code);

  /// Currency of all the transactions of this account. When you change this currency all transactions in this account
  /// will have the new currency but their amount/value will remain the same.
  CurrencyInDB currency;

  SupportedIcon get icon => SupportedIconService.instance.getIconByID(iconId);
}
