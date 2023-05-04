import 'package:finlytics/core/database/db.service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

enum AccountDataFilter { income, expense, balance }

class AccountService extends ChangeNotifier {
  final _tableName = 'accounts';

  // --- CLASS DEPENDENCIES ---
  AccountService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---
  Future<void> insertAccount(Account account) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      account.toDB(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final db = await _dbService!.database;

    await db.update(_tableName, account.toDB(),
        where: 'id = ?', whereArgs: [account.id]);

    notifyListeners();
  }

  Future<Account?> getAccountByID(String idToFind) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        where: 'id = ?', whereArgs: [idToFind], limit: 1);

    return maps.isEmpty ? null : Account.fromDB(maps.first);
  }

  Future<List<Account>> getAccounts({int? limit}) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableName, limit: limit);

    return [
      for (var i = 0; i < maps.length; i++) await Account.fromDB(maps[i])
    ];
  }

  String _joinAccountAndRate(DateTime? date) => '''
    LEFT JOIN
      (
          SELECT currencyCode,
                  exchangeRate
            FROM exchangeRates er
            WHERE date = (
                            SELECT MAX(date) 
                              FROM exchangeRates
                              WHERE currencyCode = er.currencyCode 
                              ${date != null ? 'AND  date <= ?' : ''}
                        )
            ORDER BY currencyCode
      )
      AS excRate ON accounts.currency = excRate.currencyCode
    ''';

  /// Get the amount of money (in the account currency) that an account have in a certain period of time, specified in the [date] param. If the [date] param is null, it will return the money of the account right now.
  Future<double> getAccountMoney(
      {required Account account, DateTime? date}) async {
    return await getAccountsMoney(
        accounts: [account], date: date, convertToPreferredCurrency: false);
  }

  Future<double> getAccountsMoney(
      {required List<Account> accounts,
      DateTime? date,
      bool convertToPreferredCurrency = true}) async {
    final db = await _dbService!.database;

    date ??= DateTime.now();

    final accountIds = accounts.map((account) => account.id).toList();

    final result = await db.rawQuery("""
      SELECT COALESCE(SUM(accounts.iniValue ${convertToPreferredCurrency ? ' * COALESCE(excRate.exchangeRate, 1)' : ''} ), 0) AS balance
      FROM accounts
          ${convertToPreferredCurrency ? _joinAccountAndRate(date) : ''}
          WHERE accounts.id IN (${List.filled(accountIds.length, '?').join(', ')})
      """, [
      if (convertToPreferredCurrency) DateFormat('yyyy-MM-dd').format(date),
      ...accountIds
    ]);

    return (result.isNotEmpty
            ? (result.first['balance'] as num).toDouble()
            : 0) +
        await getAccountsData(
          accounts: accounts,
          accountDataFilter: AccountDataFilter.balance,
          convertToPreferredCurrency: convertToPreferredCurrency,
          endDate: date,
        );
  }

  Future<double> getAccountsData(
      {required List<Account> accounts,
      required AccountDataFilter accountDataFilter,
      DateTime? endDate,
      DateTime? startDate,
      bool convertToPreferredCurrency = true}) async {
    final db = await _dbService!.database;

    final accountIds = accounts.map((account) => account.id).toList();

    final result = await db.rawQuery("""
        SELECT COALESCE(SUM(t.value ${convertToPreferredCurrency ? ' * COALESCE(excRate.exchangeRate, 1)' : ''}), 0) 
        AS balance
          FROM accounts
              LEFT JOIN
              (
                  SELECT value,
                          accountID
                    FROM transactions
                    WHERE isHidden = 0      
                    ${endDate != null ? ' AND date <= ?' : ''} 
                    ${startDate != null ? ' AND date >= ?' : ''} 
                    ${accountDataFilter == AccountDataFilter.expense ? 'AND value < 0' : ''} 
                    ${accountDataFilter == AccountDataFilter.income ? 'AND value > 0' : ''} 
              )
              AS t ON accounts.id = t.accountID
              ${convertToPreferredCurrency ? _joinAccountAndRate(endDate) : ''}
        WHERE accounts.id IN (${List.filled(accountIds.length, '?').join(', ')})   
      """, [
      if (endDate != null) endDate.toIso8601String(),
      if (startDate != null) startDate.toIso8601String(),
      if (endDate != null && convertToPreferredCurrency)
        DateFormat('yyyy-MM-dd').format(endDate),
      ...accountIds
    ]);

    // TODO: Handle transfers between accounts

    return result.isNotEmpty ? (result.first['balance'] as num).toDouble() : 0;
  }

  Future<double> getAccountsMoneyVariation(
      {required List<Account> accounts,
      DateTime? startDate,
      DateTime? endDate,
      bool convertToPreferredCurrency = true}) async {
    endDate ??= DateTime.now();

    double accountsBalanceStartPeriod = 0.0;

    if (startDate != null) {
      accountsBalanceStartPeriod = await getAccountsMoney(
          accounts: accounts,
          date: startDate,
          convertToPreferredCurrency: convertToPreferredCurrency);
    } else {
      for (var acc in accounts) {
        accountsBalanceStartPeriod += await getAccountsMoney(
            accounts: [acc],
            date: acc.date,
            convertToPreferredCurrency: convertToPreferredCurrency);
      }
    }

    final accountsBalanceEndPeriod = await getAccountsMoney(
        accounts: accounts,
        date: endDate,
        convertToPreferredCurrency: convertToPreferredCurrency);

    return (accountsBalanceEndPeriod - accountsBalanceStartPeriod) /
        accountsBalanceStartPeriod;
  }
}
