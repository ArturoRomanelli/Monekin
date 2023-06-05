import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';

class TransactionService {
  final DatabaseImpl db;

  TransactionService._(this.db);
  static final TransactionService instance =
      TransactionService._(DatabaseImpl.instance);

  Future<int> insertTransaction(TransactionInDB transaction) {
    return db.into(db.transactions).insert(transaction);
  }

  Future<int> insertOrUpdateTransaction(TransactionInDB transaction) {
    return db
        .into(db.transactions)
        .insert(transaction, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteTransaction(String transactionId) {
    return (db.delete(db.transactions)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .go();
  }

  Stream<List<MoneyTransaction>> getTransactions(
      {Expression<bool> Function(
              Transactions transaction,
              Accounts account,
              Currencies accountCurrency,
              Accounts receivingAccount,
              Currencies receivingAccountCurrency,
              Categories c,
              Categories)?
          predicate,
      OrderBy Function(
              Transactions transaction,
              Accounts account,
              Currencies accountCurrency,
              Accounts receivingAccount,
              Currencies receivingAccountCurrency,
              Categories c,
              Categories)?
          orderBy,
      int? limit,
      int? offset,
      bool includeTransactionsFromRecurrent = true}) {
    return db
        .getTransactionsWithFullData(
          predicate: predicate,
          orderBy: orderBy,
          limit: (t, a, accountCurrency, ra, receivingAccountCurrency, c, pc) =>
              Limit(limit ?? -1, offset),
        )
        .watch();
  }

  Stream<MoneyTransaction?> getTransactionById(String id) {
    return getTransactions(
            predicate: (transaction, account, accountCurrency, receivingAccount,
                    receivingAccountCurrency, c, p6) =>
                transaction.id.equals(id),
            limit: 1)
        .map((res) => res.firstOrNull);
  }
}
