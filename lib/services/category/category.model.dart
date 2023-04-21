import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/supported_icon/supported_icon.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';

class Category {
  final String id;
  String name;
  SupportedIcon icon;

  String? _color;
  String? _type;
  Category? parentCategory;

  String get color => _color ?? parentCategory!.color;
  String get type => _type ?? parentCategory!.type;

  set color(String newColor) {
    if (isMainCategory) {
      _color = newColor;
    } else {
      throw Exception('You can not set the color of a subcategory');
    }
  }

  set type(String newType) {
    if (isMainCategory) {
      _type = newType;
    } else {
      throw Exception('You can not set the type of a subcategory');
    }
  }

  bool get isMainCategory => parentCategory == null;
  bool get isChildCategory => !isMainCategory;

  Category._(
      {required this.id,
      required this.name,
      required this.icon,
      String? color,
      String? type,
      this.parentCategory})
      : assert((color != null && type != null) || parentCategory != null),
        _color = color,
        _type = type;

  Category.childCategory(
      {required this.id,
      required this.name,
      required this.icon,
      required this.parentCategory});

  Category.mainCategory({
    required this.id,
    required this.name,
    required this.icon,
    required String color,
    required String type,
  })  : _color = color,
        _type = type;

  /// Convert this entity to the format that it has in the database. This is usually a plain object, without nested data/objects.
  Map<String, dynamic> toDB() => {
        'id': id,
        'name': name,
        'icon': icon.id,
        'type': _type,
        'color': _color,
        'parentCategoryID': parentCategory?.id,
      };

  /// Convert a row of this entity in the database to this class
  static Future<Category> fromDB(Map<String, dynamic> data) async => Category._(
      id: data['id'],
      name: data['name'],
      icon: SupportedIconService.instance.getIconByID(data['icon']),
      color: data['color'],
      type: data['type'],
      parentCategory: data['parentCategoryID'] != null
          ? await CategoryService(DbService.instance)
              .getCategoryById(data['parentCategoryID'])
          : null);
}
