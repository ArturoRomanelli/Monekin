import 'dart:convert';
import 'dart:io' show Directory, File, Platform, FileMode;

import 'package:file_picker/file_picker.dart';
import 'package:finlytics/core/database/services/category/categoryService.dart';
import 'package:finlytics/core/utils/get_download_path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
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
      String script = await rootBundle.loadString('assets/sql/schema.sql');
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
          await rootBundle.loadString('assets/sql/default_categories.json');

      CategoryService(this).initializeCategories(jsonDecode(defaultCategories));
    }, version: 1);

    return _database!;
  }

  Future<void> downloadDatabaseFile(BuildContext context) async {
    final messeger = ScaffoldMessenger.of(context);
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    List<int> dbFileInBytes = await File(await _databasePath).readAsBytes();

    String downloadPath = await getDownloadPath();
    downloadPath = '${downloadPath}Finlytics.db';

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsBytes(dbFileInBytes);

    messeger.showSnackBar(SnackBar(
        content: Text('Base de datos descargada con exito en $downloadPath')));
  }

  Future<void> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // Delete the previous database
      String path = await _databasePath;
      await deleteDatabase(path);

      // Load the new database
      await file.copy(path);
    }
  }
}
