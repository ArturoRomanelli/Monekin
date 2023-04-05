import 'package:json_annotation/json_annotation.dart';

part 'category.model.g.dart';

abstract class CategoryBase {
  final String id;
  String name;
  String icon;

  CategoryBase({
    required this.id,
    required this.name,
    required this.icon,
  });

  CategoryBase.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        icon = json['icon'];
}

class Category extends CategoryBase {
  String? _color;
  String? _type;
  MainCategory? parentCategory;

  String get color => _color ?? parentCategory!.color;
  String get type => _type ?? parentCategory!.type;

  bool get isMainCategory => parentCategory != null;
  bool get isChildCategory => !isMainCategory;

  Category(
      {required String id,
      required String name,
      required String icon,
      String? color,
      String? type,
      this.parentCategory})
      : assert((color != null && type != null) || parentCategory != null),
        _color = color,
        _type = type,
        super(
          id: id,
          name: name,
          icon: icon,
        );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        type: json['type'] as String?,
        color: json['color'] as String?,
        parentCategory: json['parentCategory'] == null
            ? null
            : MainCategory.fromJson(
                json['parentCategory'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'icon': icon,
        'type': _type,
        'color': _color,
        'parentCategory': parentCategory,
      };
}

@JsonSerializable()
class MainCategory extends CategoryBase {
  /// The color of the category and its subcategories
  String color;

  String type;

  MainCategory({
    required String id,
    required String name,
    required String icon,
    required this.color,
    required this.type,
  }) : super(
          id: id,
          name: name,
          icon: icon,
        );

  factory MainCategory.fromJson(Map<String, dynamic> json) =>
      _$MainCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MainCategoryToJson(this);
}

@JsonSerializable()
class ChildCategory extends CategoryBase {
  MainCategory parentCategory;

  ChildCategory({
    required String id,
    required String name,
    required String icon,
    required this.parentCategory,
  }) : super(
          id: id,
          name: name,
          icon: icon,
        );

  factory ChildCategory.fromJson(Map<String, dynamic> json) =>
      _$ChildCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ChildCategoryToJson(this);
}
