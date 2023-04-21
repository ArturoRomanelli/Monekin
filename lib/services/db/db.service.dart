import 'dart:convert';
import 'dart:io' show Directory, File, Platform, FileMode;

import 'package:finlytics/services/category/categoryService.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DbService {
  DbService._();

  static final DbService instance = DbService._();
  static Database? _database;

  final _fileName = 'app-data.db';

  Future<String> get _databasePath async =>
      join(await getDatabasesPath(), _fileName);

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
        await _databasePath, onCreate: (db, version) async {
      String script = await rootBundle.loadString('lib/assets/sql/schema.sql');
      // Get and run the statements

      final batch = db.batch();
      script.split(';').forEach((statement) async {
        statement = statement.trim();

        if (statement.isNotEmpty) {
          batch.execute(statement);
        }
      });

      await batch.commit(noResult: true);

      String defaultCategories =
          await rootBundle.loadString('lib/assets/sql/default_categories.json');

      CategoryService(this).initializeCategories(jsonDecode(defaultCategories));
    }, version: 1);

    return _database!;
  }

  Future<void> downloadDatabaseFile(BuildContext context) async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    File file = File(await _databasePath);
    List<int> bytes = await file.readAsBytes();

    String documentsPath = (await getApplicationDocumentsDirectory()).path;

    String downloadPath = documentsPath;

    if (!Platform.isAndroid) {
      downloadPath = (await getDownloadsDirectory())!.path;
    } else if ((await Directory('/storage/emulated/0/Download').exists())) {
      downloadPath = '/storage/emulated/0/Download/';
    }

    downloadPath = '${downloadPath}Finlytics.db';

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Base de datos descargada con exito en $downloadPath')));
  }
}
