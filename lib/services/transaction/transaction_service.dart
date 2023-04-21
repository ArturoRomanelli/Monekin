import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/transaction/transaction.model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MoneyTransactionService extends ChangeNotifier {
  final _tableName = 'transactions';

  // --- CLASS DEPENDENCIES ---
  MoneyTransactionService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---

  Future<void> insertMoneyTransaction(MoneyTransaction transaction) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      transaction.toDB(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<void> insertOrUpdateMoneyTransaction(
      MoneyTransaction transaction) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      transaction.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<void> updateMoneyTransaction(MoneyTransaction transaction) async {
    final db = await _dbService!.database;

    await db.update(
      _tableName,
      transaction.toDB(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );

    notifyListeners();
  }

  Future<void> deleteMoneyTransaction(String transactionID) async {
    final db = await _dbService!.database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [transactionID],
    );

    notifyListeners();
  }

  Future<List<MoneyTransaction>> getMoneyTransactions() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return [
      for (var i = 0; i < maps.length; i++)
        await MoneyTransaction.fromDB(maps[i])
    ];
  }

  Future<MoneyTransaction?> getMoneyTransactionById(String id) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);

    return maps.isEmpty ? null : MoneyTransaction.fromDB(maps.first);
  }
}
