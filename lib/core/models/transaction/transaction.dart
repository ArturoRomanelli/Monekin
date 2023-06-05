import 'package:equatable/equatable.dart';
import 'package:finlytics/app/transactions/widgets/interval_selector_help.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

enum TransactionPeriodicity { day, week, month, year }

enum TransactionType { income, expense, transfer }

enum TransactionStatus {
  voided,
  pending,
  reconcilied,
  unreconcilied;

  IconData get icon {
    if (this == voided) return Icons.block_rounded;
    if (this == pending) return Icons.hourglass_full_rounded;
    if (this == unreconcilied) return Icons.warning_rounded;
    if (this == reconcilied) return Icons.check_circle_rounded;

    return Icons.question_mark;
  }

  Color get color {
    if (this == voided) return Colors.red;
    if (this == pending) return Colors.amber;
    if (this == unreconcilied) return Colors.amber;
    if (this == reconcilied) return Colors.green;

    return Colors.grey;
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
}
