import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

enum AccountType {
  /// A normal type of account The default type
  normal,

  /// This type of accounts can not have transactions. You only can add and withdraw money from it from other accounts
  saving;

  IconData get icon {
    if (this == normal) {
      return Icons.wallet;
    } else if (this == saving) {
      return Icons.savings;
    }

    return Icons.question_mark;
  }

  String title(BuildContext context) {
    final t = Translations.of(context);

    if (this == normal) {
      return t.account.types.normal;
    } else if (this == saving) {
      return t.account.types.saving;
    }

    return '';
  }

  String description(BuildContext context) {
    final t = Translations.of(context);

    if (this == normal) {
      return t.account.types.normal_descr;
    } else if (this == saving) {
      return t.account.types.saving_descr;
    }

    return '';
  }
}

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

  static Account fromDB(AccountInDB account, CurrencyInDB currency) => Account(
      id: account.id,
      currency: currency,
      iniValue: account.iniValue,
      date: account.date,
      description: account.description,
      iban: account.iban,
      swift: account.swift,
      name: account.name,
      iconId: account.iconId,
      type: account.type);
}
