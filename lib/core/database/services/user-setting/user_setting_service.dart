import 'package:finlytics/core/database/database_impl.dart';
import 'package:drift/drift.dart';

/// The keys of the avalaible settings of the app
enum SettingKey { preferredCurrency, userName, avatar }

class UserSettingService {
  final DatabaseImpl db;

  UserSettingService._(this.db);
  static final UserSettingService instance =
      UserSettingService._(DatabaseImpl.instance);

  Future<int> setSetting(SettingKey settingKey, String? settingValue) async {
    return db.into(db.userSettings).insert(
        UserSetting(settingKey: settingKey.name, settingValue: settingValue),
        mode: InsertMode.insertOrReplace);
  }

  Stream<String?> getSetting(SettingKey settingKey) {
    return (db.select(db.userSettings)
          ..where((tbl) => tbl.settingKey.equals(settingKey.name)))
        .map((e) => e.settingValue)
        .watchSingleOrNull();
  }
}
