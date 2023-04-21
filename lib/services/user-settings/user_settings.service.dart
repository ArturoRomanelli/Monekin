import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class UserSettingsService extends ChangeNotifier {
  final _tableName = 'userSettings';

  // --- CLASS DEPENDENCIES ---
  UserSettingsService(this._dbService);
  final DbService? _dbService;

  setSetting(String settingKey, String settingValue) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      {
        'settingKey': settingKey,
        'settingValue': settingValue,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<String?> getSetting(String settingKey) async {
    final db = await _dbService!.database;

    final maps = await db.query(_tableName,
        columns: ['settingValue'],
        limit: 1,
        where: 'settingKey = ?',
        whereArgs: [settingKey]);

    return maps.isEmpty ? null : maps.first['settingValue'] as String;
  }
}
