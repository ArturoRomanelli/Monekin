import 'package:finlytics/core/database/database_impl.dart';

import '../../services/supported_icon/supported_icon_service.dart';
import '../supported-icon/supported_icon.dart';

class Category extends CategoryInDB {
  String? _color;
  String? _type;

  @override
  String get color => _color ?? parentCategory!.color;

  @override
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

  Category(
      {required super.id,
      required super.name,
      required super.iconId,
      String? color,
      String? type,
      CategoryInDB? parentCategory})
      : _color = color,
        _type = type,
        parentCategory =
            parentCategory != null ? fromDB(parentCategory, null) : null,
        super(parentCategoryID: parentCategory?.id);

  Category? parentCategory;

  /// Returns whether the category is a main (or root) category or not
  bool get isMainCategory => parentCategoryID == null;

  /// Returns whether the category is a child of another category or not
  bool get isChildCategory => !isMainCategory;

  SupportedIcon get icon => SupportedIconService.instance.getIconByID(iconId);

  static Category fromDB(CategoryInDB cat, CategoryInDB? parentCategory) =>
      Category(
          id: cat.id,
          name: cat.name,
          iconId: cat.iconId,
          parentCategory: parentCategory,
          color: cat.color,
          type: cat.type);
}
