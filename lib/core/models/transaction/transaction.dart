import 'package:equatable/equatable.dart';
import 'package:finlytics/app/transactions/widgets/interval_selector_help.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

enum TransactionPeriodicity {
  day,
  week,
  month,
  year;

  String periodText(BuildContext context, int n) {
    final t = Translations.of(context);

    if (this == day) {
      return t.general.time.ranges.day(n: n);
    } else if (this == week) {
      return t.general.time.ranges.week(n: n);
    } else if (this == month) {
      return t.general.time.ranges.month(n: n);
    } else if (this == year) {
      return t.general.time.ranges.year(n: n);
    }

    return '';
  }

  String allThePeriodsText(BuildContext context) {
    final t = Translations.of(context);

    if (this == day) {
      return t.general.time.all.diary;
    } else if (this == week) {
      return t.general.time.all.weekly;
    } else if (this == month) {
      return t.general.time.all.monthly;
    } else if (this == year) {
      return t.general.time.all.annually;
    }

    return '';
  }
}

enum TransactionType { income, expense, transfer }

enum TransactionStatus {
  voided,
  pending,
  reconciled,
  unreconciled;

  IconData get icon {
    if (this == voided) return Icons.block_rounded;
    if (this == pending) return Icons.hourglass_full_rounded;
    if (this == unreconciled) return Icons.cloud_off_rounded;
    if (this == reconciled) return Icons.check_circle_rounded;

    return Icons.question_mark;
  }

  Color get color {
    if (this == voided) return Colors.red;
    if (this == pending) return Colors.amber;
    if (this == unreconciled) return Colors.orange;
    if (this == reconciled) return Colors.green;

    return Colors.grey;
  }

  String displayName(BuildContext context) {
    final t = Translations.of(context);

    if (this == voided) return t.transaction.status.voided;
    if (this == pending) return t.transaction.status.pending;
    if (this == unreconciled) return t.transaction.status.unreconciled;
    if (this == reconciled) return t.transaction.status.reconciled;

    return '';
  }

  String description(BuildContext context) {
    final t = Translations.of(context);

    if (this == voided) return t.transaction.status.voided_descr;
    if (this == pending) return t.transaction.status.pending_descr;
    if (this == unreconciled) return t.transaction.status.unreconciled_descr;
    if (this == reconciled) return t.transaction.status.reconciled_descr;

    return '';
  }
}

class MoneyTransaction extends TransactionInDB {
  Category? category;
  Account account;
  Account? receivingAccount;

  MoneyTransaction({
    required super.id,
    required super.date,
    required super.value,
    required super.isHidden,
    super.notes,
    super.title,
    super.status,
    super.valueInDestiny,
    required AccountInDB account,
    AccountInDB? receivingAccount,
    required CurrencyInDB accountCurrency,
    CurrencyInDB? receivingAccountCurrency,
    CategoryInDB? category,
    CategoryInDB? parentCategory,
  })  : category =
            category != null ? Category.fromDB(category, parentCategory) : null,
        account = Account.fromDB(account, accountCurrency),
        receivingAccount =
            receivingAccount != null && receivingAccountCurrency != null
                ? Account.fromDB(receivingAccount, receivingAccountCurrency)
                : null,
        super(
            accountID: account.id,
            categoryID: category?.id,
            receivingAccountID: receivingAccount?.id);

  MoneyTransaction.incomeOrExpense({
    required super.id,
    required this.account,
    required super.date,
    required super.value,
    super.notes,
    super.title,
    super.isHidden = false,
    super.status,
    required this.category,
  }) : super(accountID: account.id, categoryID: category?.id);

  MoneyTransaction.transfer(
      {required super.id,
      required this.account,
      required super.date,
      required super.value,
      super.notes,
      super.title,
      super.isHidden = false,
      super.status,
      required this.receivingAccount,
      super.valueInDestiny})
      : super(accountID: account.id, receivingAccountID: receivingAccount?.id);

  bool get isTransfer => receivingAccountID != null;
  bool get isIncomeOrExpense => categoryID != null;

  String get displayName =>
      title ?? (isIncomeOrExpense ? category!.name : 'Transfer');

  /// Get the color that represent this category. Will be the category color when the transaction is an income or an expense, and the primary color of the app otherwise
  Color color(context) => isIncomeOrExpense
      ? ColorHex.get(category!.color)
      : Theme.of(context).colorScheme.primary;

  TransactionType get type => isTransfer
      ? TransactionType.transfer
      : value < 0
          ? TransactionType.expense
          : TransactionType.income;
}

enum RuleUntilMode { infinity, date, nTimes }

class RuleRecurrentLimit extends Equatable {
  final DateTime? endDate;
  final int? remainingIterations;

  const RuleRecurrentLimit({this.endDate, this.remainingIterations})
      : assert(!(endDate != null && remainingIterations != null));

  const RuleRecurrentLimit.infinite()
      : endDate = null,
        remainingIterations = null;

  RuleUntilMode get untilMode {
    if (endDate != null) {
      return RuleUntilMode.date;
    } else if (remainingIterations != null) {
      return RuleUntilMode.date;
    }
    return RuleUntilMode.infinity;
  }

  @override
  List<dynamic> get props => [endDate, remainingIterations];
}

class MoneyRecurrentRule extends MoneyTransaction {
  RuleRecurrentLimit recurrentLimit;
  int intervalEach;
  TransactionPeriodicity intervalPeriod;

  MoneyRecurrentRule(
      {required super.id,
      required DateTime nextPaymentDate,
      required super.value,
      required super.account,
      required super.accountCurrency,
      super.category,
      super.notes,
      super.parentCategory,
      super.receivingAccount,
      super.receivingAccountCurrency,
      super.title,
      super.valueInDestiny,
      required this.intervalPeriod,
      required this.intervalEach,
      DateTime? endDate,
      int? remainingTransactions})
      : recurrentLimit = RuleRecurrentLimit(
            endDate: endDate, remainingIterations: remainingTransactions),
        super(
            date: nextPaymentDate,
            isHidden: false,
            status: TransactionStatus.pending);

  RecurrencyData get recurrencyData =>
      recurrentLimit.untilMode == RuleUntilMode.infinity
          ? RecurrencyData.infinite(
              intervalPeriod: intervalPeriod, intervalEach: intervalEach)
          : RecurrencyData.withLimit(
              ruleRecurrentLimit: recurrentLimit,
              intervalPeriod: intervalPeriod,
              intervalEach: intervalEach);

  /// Since the next payment date is stored in the `date` variable, this getter gets the payment after this date. That is, when a payment is made,
  /// the `date` variable will change to this new value.
  ///
  /// The function will return `null` in the event that there are no more payments to be made after the immediately following one (stored in the
  /// `date` variable).
  DateTime? get followingDateToNext {
    if (recurrentLimit.remainingIterations != null &&
        recurrentLimit.remainingIterations! <= 1) {
      return null;
    }

    DateTime? toReturn;

    if (intervalPeriod == TransactionPeriodicity.day) {
      toReturn = date.add(Duration(days: intervalEach));
    } else if (intervalPeriod == TransactionPeriodicity.week) {
      toReturn = date.add(Duration(days: intervalEach * 7));
    } else if (intervalPeriod == TransactionPeriodicity.month) {
      toReturn = date.copyWith(month: date.month + intervalEach);

      if (toReturn.month > date.month + intervalEach) {
        toReturn = date.copyWith(month: date.month + intervalEach + 1);
      }
    } else if (intervalPeriod == TransactionPeriodicity.year) {
      toReturn = date.copyWith(year: date.year + intervalEach);
    }

    if (recurrentLimit.endDate != null &&
        toReturn!.compareTo(recurrentLimit.endDate!) <= 0) {
      return null;
    }

    return toReturn;
  }
}
