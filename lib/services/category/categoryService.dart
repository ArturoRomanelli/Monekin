import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CategoryService extends ChangeNotifier {
  final _tableName = 'categories';

  // --- CLASS DEPENDENCIES ---
  CategoryService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---

  Future<void> insertCategory(Category category) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      category.toDB(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<void> insertOrUpdateCategory(Category category) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableName,
      category.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    final db = await _dbService!.database;

    await db.update(
      _tableName,
      category.toDB(),
      where: 'id = ?',
      whereArgs: [category.id],
    );

    notifyListeners();
  }

  Future<void> deleteCategory(String categoryID) async {
    final db = await _dbService!.database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [categoryID],
    );

    notifyListeners();
  }

  Future<List<Category>> getMainCategories() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableName, where: 'parentCategoryID IS NULL');

    return [
      for (var i = 0; i < maps.length; i++) await Category.fromDB(maps[i])
    ];
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);

    return maps.isEmpty ? null : Category.fromDB(maps.first);
  }

  Future<List<Category>> getChildCategories({String? parentId}) async {
    final db = await _dbService!.database;

    final whereStatement =
        "parentCategoryID IS NOT NULL${parentId != null ? ' AND parentCategoryID = ?' : ''}";

    final List<Map<String, dynamic>> maps = await db.query(_tableName,
        where: whereStatement, whereArgs: [if (parentId != null) parentId]);

    return [
      for (var i = 0; i < maps.length; i++) await Category.fromDB(maps[i])
    ];
  }

  Future<void> initializeCategories(dynamic json) async {
    for (var category in json) {
      final categoryToPush = Category.mainCategory(
          id: const Uuid().v4(),
          name: category['names']['es'],
          icon: SupportedIconService.instance.getIconByID(category['icon']),
          color: category['color'],
          type: category['type']);

      await insertCategory(categoryToPush);

      if (category['subcategories'] != null) {
        for (var subcategory in category['subcategories']) {
          await insertCategory(Category.childCategory(
              id: const Uuid().v4(),
              name: subcategory['names']['es'],
              icon: SupportedIconService.instance
                  .getIconByID(subcategory['icon']),
              parentCategory: categoryToPush));
        }
      }
    }
  }
}
