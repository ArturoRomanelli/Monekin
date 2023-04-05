import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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

    // Change default factory when not mobile
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Open the database and store the reference.
    _database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the `path` package is best practice
        // to ensure the path is correctly constructed for each platform.
        join(await getDatabasesPath(), 'app-data.db'),
        onCreate: (db, version) async {
      String script = await rootBundle.loadString("lib/assets/sql/schema.sql");
      // Get and run the statements
      script.split(";").forEach((statement) {
        statement = statement.trim();

        if (statement.isNotEmpty) {
          db.execute(statement);
        }
      });
    }, version: 1);

    return _database!;
  }
}
