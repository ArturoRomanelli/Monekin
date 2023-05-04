import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supported_icon.g.dart';

@JsonSerializable()
class SupportedIcon {
  final String id;

  final String scope;

  String get urlToAssets => 'lib/assets/icons/$scope/$id.svg';

  SupportedIcon({required this.id, required this.scope});

  factory SupportedIcon.fromJson(Map<String, dynamic> json) =>
      _$SupportedIconFromJson(json);

  Map<String, dynamic> toJson() => _$SupportedIconToJson(this);

  /// Display the icon in any widget
  SvgPicture display({double size = 22, Color? color}) {
    return SvgPicture.asset(
      urlToAssets,
      height: size,
      width: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
