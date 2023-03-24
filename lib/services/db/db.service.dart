import 'package:finlytics/services/account/account.model.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  Database? _database;

  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    _database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), 'app-data.db'),
        onCreate: (db, version) => {
              db.execute('''CREATE TABLE accounts (
                  id TEXT PRIMARY KEY,
                  name TEXT UNIQUE NOT NULL,
                  iniValue REAL NOT NULL,
                  date TEXT NOT NULL,
                  text TEXT,
                  type TEXT NOT NULL,
                  icon TEXT NOT NULL,
                  currency TEXT NOT NULL,
                  iban TEXT,
                  swift TEXT
                );''')
            },
        version: 1);

    return _database!;
  }

  Future<void> insertAccount(Account account) async {
    final db = await _getDatabase();

    await db.insert(
      'accounts',
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<List<Account>> getAccounts() async {
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('accounts');

    return List.generate(maps.length, (i) {
      return Account.fromJson(maps[i]);
    });
  }
}
