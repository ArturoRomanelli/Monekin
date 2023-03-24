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

@JsonSerializable(explicitToJson: true)
class MainCategory extends CategoryBase {
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

@JsonSerializable(explicitToJson: true)
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
