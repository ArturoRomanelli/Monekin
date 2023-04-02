import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  DbService._();

  static final DbService instance = DbService._();
  static Database? _database;

  // Getter database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();

    return _database!;
  }

  Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    _database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the `path` package is best practice
        // to ensure the path is correctly constructed for each platform.
        join(await getDatabasesPath(), 'app-data.db'),
        onCreate: (db, version) async =>
            {db.execute(await rootBundle.loadString("assets/sql/schema.sql"))},
        version: 1);

    return _database!;
  }
}
