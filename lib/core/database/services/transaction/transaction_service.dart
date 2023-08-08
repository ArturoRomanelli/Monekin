import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:monekin/core/database/app_db.dart';
import 'package:monekin/core/models/transaction/transaction.dart';

class TransactionService {
  final AppDB db;

  TransactionService._(this.db);
  static final TransactionService instance =
      TransactionService._(AppDB.instance);

  Future<int> insertTransaction(TransactionInDB transaction) async {
    final toReturn = await db.into(db.transactions).insert(transaction);

    // To update the getAccountsData() function results
    // TODO: Check why we need this. The function already listen to changes in the transactions table
    db.markTablesUpdated([db.accounts]);
    return toReturn;
  }

  Future<int> insertOrUpdateTransaction(TransactionInDB transaction) async {
    final toReturn = await db
        .into(db.transactions)
        .insert(transaction, mode: InsertMode.insertOrReplace);

    // To update the getAccountsData() function results
    // TODO: Check why we need this. The function already listen to changes in the transactions table
    db.markTablesUpdated([db.accounts]);

    return toReturn;
  }

  Future<int> deleteTransaction(String transactionId) {
    return (db.delete(db.transactions)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .go();
  }

  Stream<List<MoneyTransaction>> getTransactions({
    Expression<bool> Function(
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
  }) {
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
