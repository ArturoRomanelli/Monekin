import 'package:json_annotation/json_annotation.dart';

part 'supported_icon.g.dart';

@JsonSerializable()
class SupportedIcon {
  final String id;

  final String scope;

  String get urlToAssets => "lib/assets/icons/$scope/$id.svg";

  SupportedIcon({required this.id, required this.scope});

  factory SupportedIcon.fromJson(Map<String, dynamic> json) =>
      _$SupportedIconFromJson(json);

  Map<String, dynamic> toJson() => _$SupportedIconToJson(this);
}
