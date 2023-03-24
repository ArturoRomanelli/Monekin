import 'package:finlytics/services/account/account.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.model.g.dart';

enum RecurrentOption {
  week,
  month,
  year,
}

abstract class TransactionBase {
  final String id;
  DateTime date;
  double value;
  String? text;
  Map<String, dynamic>? repeat;

  Account account;

  TransactionBase({
    required this.id,
    required this.date,
    required this.value,
    this.text,
    this.repeat,
    required this.account,
  });

  TransactionBase.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = DateTime.parse(json['date']),
        value = json['value'],
        text = json['text'],
        repeat = json['repeat'],
        account = Account.fromJson(json['account']);
}

@JsonSerializable(explicitToJson: true)
class IncomeOrExpense extends TransactionBase {
  dynamic category;

  IncomeOrExpense({
    required String id,
    required DateTime date,
    required double value,
    String? text,
    Map<String, dynamic>? repeat,
    required this.category,
    required Account account,
  }) : super(
          id: id,
          date: date,
          value: value,
          text: text,
          repeat: repeat,
          account: account,
        );

  factory IncomeOrExpense.fromJson(Map<String, dynamic> json) =>
      _$IncomeOrExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeOrExpenseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Transfer extends TransactionBase {
  Account receivingAccount;
  double? valueInDestiny;

  Transfer({
    required String id,
    required DateTime date,
    required double value,
    String? text,
    Map<String, dynamic>? repeat,
    required this.receivingAccount,
    this.valueInDestiny,
    required Account account,
  }) : super(
          id: id,
          date: date,
          value: value,
          text: text,
          repeat: repeat,
          account: account,
        );

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);

  Map<String, dynamic> toJson() => _$TransferToJson(this);
}
