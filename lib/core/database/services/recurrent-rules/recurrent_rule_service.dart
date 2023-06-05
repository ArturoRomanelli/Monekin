import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:finlytics/core/database/database_impl.dart';

import '../../../models/transaction/transaction.dart';

class RecurrentRuleService {
  final DatabaseImpl db;

  RecurrentRuleService._(this.db);
  static final RecurrentRuleService instance =
      RecurrentRuleService._(DatabaseImpl.instance);

  Future<int> insertRecurrentRule(RecurrentRuleInDB recurrentRule) {
    return db.into(db.recurrentRules).insert(recurrentRule);
  }

  Future<int> insertOrUpdateRecurrentRule(RecurrentRuleInDB recurrentRule) {
    return db
        .into(db.recurrentRules)
        .insert(recurrentRule, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteRecurrentRule(String recurrentRuleId) {
    return (db.delete(db.recurrentRules)
          ..where((tbl) => tbl.id.equals(recurrentRuleId)))
        .go();
  }

  Stream<List<MoneyRecurrentRule>> getRecurrentRules({
    Expression<bool> Function(
            RecurrentRules recurrentRule,
            Accounts account,
            Currencies accountCurrency,
            Accounts receivingAccount,
            Currencies receivingAccountCurrency,
            Categories c,
            Categories)?
        predicate,
    OrderBy Function(
            RecurrentRules recurrentRule,
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
        .getRecurrentRulesWithFullData(
          predicate: predicate,
          orderBy: orderBy,
          limit: (t, a, accountCurrency, ra, receivingAccountCurrency, c, pc) =>
              Limit(limit ?? -1, offset),
        )
        .watch();
  }

  Stream<MoneyRecurrentRule?> getRecurrentRuleById(String id) {
    return getRecurrentRules(
            predicate: (recurrentRule, account, accountCurrency,
                    receivingAccount, receivingAccountCurrency, c, p6) =>
                recurrentRule.id.equals(id),
            limit: 1)
        .map((res) => res.firstOrNull);
  }
}
