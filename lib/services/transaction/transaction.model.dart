import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/db/db.service.dart';

enum TransactionType { income, expense, transfer }

class TransactionCommon {
  final String id;

  Account account;

  DateTime date;
  double value;
  String? text;

  Category? category;

  double? valueInDestiny;

  Account? receivingAccount;

  bool get isTransfer => receivingAccount != null;
  bool get isIncomeOrExpense => category != null;

  TransactionType get type => isTransfer
      ? TransactionType.transfer
      : value < 0
          ? TransactionType.expense
          : TransactionType.income;

  TransactionCommon({
    required this.id,
    required this.account,
    required this.date,
    required this.value,
    this.text,
    this.category,
    this.valueInDestiny,
    this.receivingAccount,
  })  : assert((receivingAccount == null) != (category == null)),
        assert(category == null || valueInDestiny == null);
}

class MoneyTransaction extends TransactionCommon {
  bool isPending;
  bool isHidden;

  MoneyTransaction._({
    required super.id,
    required super.account,
    required super.date,
    required super.value,
    this.isHidden = false,
    this.isPending = false,
    super.text,
    super.category,
    super.valueInDestiny,
    super.receivingAccount,
  })  : assert((receivingAccount == null) != (category == null)),
        assert(category == null || valueInDestiny == null);

  MoneyTransaction.incomeOrExpense({
    required super.id,
    required super.account,
    required super.date,
    required super.value,
    super.text,
    this.isHidden = false,
    this.isPending = false,
    required super.category,
  });

  MoneyTransaction.transfer(
      {required super.id,
      required super.account,
      required super.date,
      required super.value,
      super.text,
      this.isHidden = false,
      this.isPending = false,
      required super.receivingAccount,
      super.valueInDestiny});

  /// Convert this entity to the format that it has in the database. This is usually a plain object, without nested data/objects.
  Map<String, dynamic> toDB() => {
        'id': id,
        'accountID': account.id,
        'date': date.toIso8601String(),
        'value': value,
        'text': text,
        'categoryID': category?.id,
        'valueInDestiny': valueInDestiny,
        'receivingAccountID': receivingAccount?.id,
        'isPending': isPending ? 1 : 0,
        'isHidden': isHidden ? 1 : 0,
      };

  /// Convert a row of this entity in the database to this class
  static Future<MoneyTransaction> fromDB(Map<String, dynamic> data) async =>
      MoneyTransaction._(
        id: data['id'],
        account: (await AccountService(DbService.instance)
            .getAccountByID(data['accountID']))!,
        receivingAccount: data['receivingAccountID'] != null
            ? (await AccountService(DbService.instance)
                .getAccountByID(data['receivingAccountID']))!
            : null,
        category: data['categoryID'] != null
            ? (await CategoryService(DbService.instance)
                .getCategoryById(data['categoryID']))!
            : null,
        date: DateTime.parse(data['date']),
        value: data['value'],
        valueInDestiny: data['valueInDestiny'],
        text: data['text'],
        isHidden: data['isHidden'] == 1 ? true : false,
        isPending: data['isPending'] == 1 ? true : false,
      );
}
