// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: json['id'] as String,
      name: json['name'] as String,
      iniValue: (json['iniValue'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      text: json['text'] as String?,
      type: json['type'] as String,
      icon: json['icon'] as String,
      currency: Account._getCurrencyByCode(json['currency'] as String),
      iban: json['iban'] as String?,
      swift: json['swift'] as String?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iniValue': instance.iniValue,
      'date': instance.date.toIso8601String(),
      'text': instance.text,
      'type': instance.type,
      'icon': instance.icon,
      'currency': Account._getCurrencyCode(instance.currency),
      'iban': instance.iban,
      'swift': instance.swift,
    };
