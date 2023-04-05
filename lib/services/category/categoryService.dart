import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/default_categories.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CategoryService extends ChangeNotifier {
  final _tableMainCategoriesName = "mainCategories";
  final _tableChildCategoriesName = "childCategories";

  // --- CLASS DEPENDENCIES ---
  CategoryService(this._dbService);
  final DbService? _dbService;

  // --- CLASS IMPLEMENTATION ---
  Future<void> insertMainCategory(MainCategory category) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableMainCategoriesName,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<void> insertChildCategory(ChildCategory category) async {
    final db = await _dbService!.database;

    await db.insert(
      _tableChildCategoriesName,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    notifyListeners();
  }

  Future<List<MainCategory>> getMainCategories() async {
    final db = await _dbService!.database;

    final List<Map<String, dynamic>> maps =
        await db.query(_tableMainCategoriesName);

    if (maps.isEmpty) {
      await initializeCategories();
      await getMainCategories();
    }

    return List.generate(maps.length, (i) {
      return MainCategory.fromJson(maps[i]);
    });
  }

  initializeCategories() async {
    for (var category in defaultCategories) {
      await insertMainCategory(MainCategory(
          id: const Uuid().v4(),
          name: category["names"]["es"],
          icon: category["icon"],
          color: category["color"],
          type: category["type"]));

      if (category["subcategory"] != null) {
        for (var subcategory in category["subcategory"]) {
          await insertChildCategory(ChildCategory(
              id: const Uuid().v4(),
              name: subcategory["names"]["es"],
              icon: subcategory["icon"],
              parentCategory: subcategory["parentCategry"]));
        }
      }
    }
  }
}
