import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class AccountService extends ChangeNotifier {
  final _tableName = "accounts";

  // --- CLASS DEPENDENCIES ---
  AccountService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---
  Future<void> insertAccount(Account account) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final db = await _dbService!.database;

    await db.update(_tableName, account.toJson(),
        where: 'id = ?', whereArgs: [account.id]);

    notifyListeners();
  }

  Future<Account?> getAccountByID(String idToFind) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        where: 'id = ?', whereArgs: [idToFind], limit: 1);

    return maps.isEmpty ? null : Account.fromJson(maps.first);
  }

  Future<List<Account>> getAccounts() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Account.fromJson(maps[i]);
    });
  }
}
