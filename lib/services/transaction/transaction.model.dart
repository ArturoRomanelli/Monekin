import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/utils/enum_from_string.dart';

enum TransactionType { income, expense, transfer }

enum TransactionStatus { voided, pending, reconcilied, unreconcilied }

class MoneyTransaction {
  final String id;

  Account account;

  DateTime date;
  double value;
  String? text;

  TransactionStatus? status;

  bool isHidden;

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

  MoneyTransaction._({
    required this.id,
    required this.account,
    required this.date,
    required this.value,
    this.isHidden = false,
    this.status,
    this.text,
    this.category,
    this.valueInDestiny,
    this.receivingAccount,
  })  : assert((receivingAccount == null) != (category == null)),
        assert(category == null || valueInDestiny == null);

  MoneyTransaction.incomeOrExpense({
    required this.id,
    required this.account,
    required this.date,
    required this.value,
    this.text,
    this.isHidden = false,
    this.status,
    required this.category,
  });

  MoneyTransaction.transfer(
      {required this.id,
      required this.account,
      required this.date,
      required this.value,
      this.text,
      this.isHidden = false,
      this.status,
      required this.receivingAccount,
      this.valueInDestiny});

  /// Convert this entity to the format that it has in the database. This is usually a plain object, without nested data/objects.
  Map<String, dynamic> toDB() => {
        'id': id,
        'accountID': account.id,
        'date': date.toIso8601String(),
        'value': value,
        'text': text,
        'categoryID': category?.id,
        'valueInDestiny': valueInDestiny,
        'status': status?.name,
        'receivingAccountID': receivingAccount?.id,
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
        status: enumFromString(TransactionStatus.values, data['status']),
        valueInDestiny: data['valueInDestiny'],
        text: data['text'],
        isHidden: data['isHidden'] == 1 ? true : false,
      );
}
