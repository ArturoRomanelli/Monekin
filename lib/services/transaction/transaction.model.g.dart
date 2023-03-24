// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeOrExpense _$IncomeOrExpenseFromJson(Map<String, dynamic> json) =>
    IncomeOrExpense(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      text: json['text'] as String?,
      repeat: json['repeat'] as Map<String, dynamic>?,
      category: json['category'],
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IncomeOrExpenseToJson(IncomeOrExpense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'text': instance.text,
      'repeat': instance.repeat,
      'account': instance.account.toJson(),
      'category': instance.category,
    };

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      text: json['text'] as String?,
      repeat: json['repeat'] as Map<String, dynamic>?,
      receivingAccount:
          Account.fromJson(json['receivingAccount'] as Map<String, dynamic>),
      valueInDestiny: (json['valueInDestiny'] as num?)?.toDouble(),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'text': instance.text,
      'repeat': instance.repeat,
      'account': instance.account.toJson(),
      'receivingAccount': instance.receivingAccount.toJson(),
      'valueInDestiny': instance.valueInDestiny,
    };
