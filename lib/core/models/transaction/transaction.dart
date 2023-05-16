import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/category/category.dart';

enum TransactionType { income, expense, transfer }

enum TransactionStatus { voided, pending, reconcilied, unreconcilied }

class MoneyTransaction extends TransactionInDB {
  Category? category;
  AccountInDB account;
  AccountInDB? receivingAccount;

  MoneyTransaction({
    required super.id,
    required this.account,
    required super.date,
    required super.value,
    required super.isHidden,
    super.note,
    super.status,
    super.valueInDestiny,
    this.receivingAccount,
    CategoryInDB? category,
    CategoryInDB? parentCategory,
  })  : category =
            category != null ? Category.fromDB(category, parentCategory) : null,
        super(
            accountID: account.id,
            categoryID: category?.id,
            receivingAccountID: receivingAccount?.id);

  MoneyTransaction.incomeOrExpense({
    required super.id,
    required this.account,
    required super.date,
    required super.value,
    super.note,
    super.isHidden = false,
    super.status,
    required this.category,
  }) : super(accountID: account.id, categoryID: category?.id);

  MoneyTransaction.transfer(
      {required super.id,
      required this.account,
      required super.date,
      required super.value,
      super.note,
      super.isHidden = false,
      super.status,
      required this.receivingAccount,
      super.valueInDestiny})
      : super(accountID: account.id, receivingAccountID: receivingAccount?.id);

  bool get isTransfer => receivingAccountID != null;
  bool get isIncomeOrExpense => categoryID != null;

  TransactionType get type => isTransfer
      ? TransactionType.transfer
      : value < 0
          ? TransactionType.expense
          : TransactionType.income;
}
