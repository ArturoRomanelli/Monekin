import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:finlytics/core/database/services/app-data/app_data_service.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/budget/budget.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/exchange-rate/exchange_rate.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database_impl.g.dart';

final databaseProvider = Provider<DatabaseImpl>(
  (ref) => DatabaseImpl.instance,
);

@DriftDatabase(
    include: {'sql/initial/tables.drift', 'sql/queries/select-full-data.drift'})
class DatabaseImpl extends _$DatabaseImpl {
  DatabaseImpl._({
    required this.dbName,
    required this.inMemory,
    required this.logStatements,
  }) : super(_openConnection(dbName, logStatements: logStatements));

  static final DatabaseImpl instance = DatabaseImpl._(
    dbName: 'database.db',
    inMemory: false,
    logStatements: false,
  );

  final String dbName;
  final bool inMemory;
  final bool logStatements;

  Future<String> get databasePath async =>
      join((await getApplicationDocumentsDirectory()).path, dbName);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        print(
            'DB found! Version ${details.versionNow} (previous was ${details.versionBefore}). Path to DB -> ${await databasePath}');

        if (details.wasCreated) {
          print('Executing seeders... Populating the database...');

          try {
            String initialSQL =
                await rootBundle.loadString('assets/sql/initial_data.sql');

            final statements = initialSQL
                .split(RegExp(r"(?<![';\/])\s*;\s*"))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            for (final sqlStatement in statements) {
              await customStatement(sqlStatement);
            }

            await customStatement(
                "INSERT INTO appData VALUES ('dbVersion', '${schemaVersion.toStringAsFixed(0)}'), ('appVersion', null), ('introSeen', 'false'), ('lastExportDate', null)");

            String defaultCategories = await rootBundle
                .loadString('assets/sql/default_categories.json');

            await CategoryService.instance
                .initializeCategories(jsonDecode(defaultCategories));

            print('Initial data correctly inserted!');
          } catch (e) {
            print('ERROR: $e');
            throw Exception(e);
          }
        }

        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (m) async {
        print('Creating database tables...');

        await m.createAll(); // create all tables

        print('Database tables created!');
      },
      onUpgrade: (m, from, to) async {
        print('Executing migrations from previous version...');
      },
    );
  }

  /// Return a WHERE clause expression that is the equivalent to the conjunction of some expressions. If no expressions are passed, the WHERE clause will have no effect.
  Expression<bool> buildExpr(List<Expression<bool>> expressions) {
    if (expressions.isEmpty) return const CustomExpression('(TRUE)');

    Expression<bool> toReturn = expressions.first;

    for (var i = 1; i < expressions.length; i++) {
      final exprToPush = expressions[i];

      toReturn = toReturn & exprToPush;
    }

    return toReturn;
  }
}

LazyDatabase _openConnection(String dbName, {bool logStatements = false}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, dbName));
    return NativeDatabase.createBackgroundConnection(file,
        logStatements: logStatements);
  });
}
