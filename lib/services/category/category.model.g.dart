// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainCategory _$MainCategoryFromJson(Map<String, dynamic> json) => MainCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$MainCategoryToJson(MainCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'type': instance.type,
    };

ChildCategory _$ChildCategoryFromJson(Map<String, dynamic> json) =>
    ChildCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      parentCategory:
          MainCategory.fromJson(json['parentCategory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChildCategoryToJson(ChildCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'parentCategory': instance.parentCategory,
    };
