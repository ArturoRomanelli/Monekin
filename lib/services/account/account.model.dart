import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.model.g.dart';

@JsonSerializable()
class Account {
  final String id;

  /// Name of the account. Must be unique, a user can not have two or more accounts with the same name
  String name;

  /// The initial value of the account, the amount of money of the account before any transaction
  double iniValue;

  /// Creation date of the account
  final DateTime date;

  /// Short description text of the account
  String? text;

  String type;

  String icon;

  /// Currency of all the transactions of this account. When you change this currency all transactions in this account
  /// will have the new currency but their amount/value will remain the same.
  @JsonKey(toJson: _getCurrencyCode, fromJson: _getCurrencyByCode)
  Currency currency;

  static String _getCurrencyCode(Currency currency) => currency.code;
  static Currency _getCurrencyByCode(String id) =>
      CurrencyService().getCurrencyByCode(id) ??
      CurrencyService().getUserDefaultCurrency();

  String? iban;
  String? swift;

  Account(
      {required this.id,
      required this.name,
      required this.iniValue,
      required this.date,
      this.text,
      required this.type,
      required this.icon,
      required this.currency,
      this.iban,
      this.swift});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
