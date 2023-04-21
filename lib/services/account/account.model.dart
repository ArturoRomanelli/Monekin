import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/supported_icon/supported_icon.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';

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

  SupportedIcon icon;

  /// Currency of all the transactions of this account. When you change this currency all transactions in this account
  /// will have the new currency but their amount/value will remain the same.
  Currency currency;

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

  /// Convert this entity to the format that it has in the database. This is usually a plain object, without nested data/objects.
  Map<String, dynamic> toDB() => {
        'id': id,
        'name': name,
        'iniValue': iniValue,
        'date': date.toIso8601String(),
        'text': text,
        'type': type,
        'icon': icon.id,
        'currency': currency.code,
        'iban': iban,
        'swift': swift,
      };

  /// Convert a row of this entity in the database to this class
  static Future<Account> fromDB(Map<String, dynamic> json) async => Account(
        id: json['id'],
        name: json['name'],
        iniValue: (json['iniValue'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        text: json['text'],
        type: json['type'],
        icon: SupportedIconService.instance.getIconByID(json['icon']),
        currency: await CurrencyService(DbService.instance)
                .getCurrencyByCode(json['currency']) ??
            await CurrencyService(DbService.instance)
                .getUserPreferredCurrency(),
        iban: json['iban'],
        swift: json['swift'],
      );
}
