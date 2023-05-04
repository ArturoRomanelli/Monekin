import 'package:finlytics/core/database/db.service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// The keys of the avalaible settings of the app
enum SettingKey { preferredCurrency, userName, avatar }

class UserSettingsService extends ChangeNotifier {
  final _tableName = 'userSettings';

  // --- CLASS DEPENDENCIES ---
  UserSettingsService(this._dbService);
  final DbService? _dbService;

  setSetting(SettingKey settingKey, String settingValue) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      {
        'settingKey': settingKey.name,
        'settingValue': settingValue,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<String?> getSetting(SettingKey settingKey) async {
    final db = await _dbService!.database;

    final maps = await db.query(_tableName,
        columns: ['settingValue'],
        limit: 1,
        where: 'settingKey = ?',
        whereArgs: [settingKey.name]);

    return maps.isEmpty ? null : maps.first['settingValue'] as String;
  }
}
