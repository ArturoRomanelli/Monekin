import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:finlytics/app/transactions/widgets/interval_selector.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:flutter/material.dart';

class RecurrencyData extends Equatable {
  final RuleRecurrentLimit? ruleRecurrentLimit;

  final int? intervalEach;
  final TransactionPeriodicity? intervalPeriod;

  const RecurrencyData.noRepeat()
      : ruleRecurrentLimit = null,
        intervalEach = null,
        intervalPeriod = null;

  const RecurrencyData.withLimit({
    required this.ruleRecurrentLimit,
    required this.intervalPeriod,
    this.intervalEach = 1,
  });

  const RecurrencyData.infinite({
    required this.intervalPeriod,
    this.intervalEach = 1,
  }) : ruleRecurrentLimit = const RuleRecurrentLimit.infinite();

  bool get isNoRecurrent => ruleRecurrentLimit == null;

  String get formText {
    if (isNoRecurrent) {
      return 'No se repite';
    } else if (ruleRecurrentLimit!.untilMode == RuleUntilMode.infinity &&
        intervalEach == 1) {
      return 'Todos los ${intervalPeriod?.name}';
    } else {
      if (ruleRecurrentLimit!.untilMode == RuleUntilMode.infinity) {
        return 'Each $intervalEach ${intervalPeriod?.name}';
      } else {
        return 'Each $intervalEach ${intervalPeriod?.name} hasta ....';
      }
    }
  }

  @override
  List<dynamic> get props => [ruleRecurrentLimit, intervalEach, intervalPeriod];
}

class IntervalSelectorHelp extends StatefulWidget {
  const IntervalSelectorHelp({super.key, required this.selectedRecurrentRule});

  final RecurrencyData selectedRecurrentRule;

  @override
  State<IntervalSelectorHelp> createState() => _IntervalSelectorHelpState();
}

class _IntervalSelectorHelpState extends State<IntervalSelectorHelp> {
  List<RecurrencyData> options = [
    const RecurrencyData.noRepeat(),
    const RecurrencyData.withLimit(
        ruleRecurrentLimit: RuleRecurrentLimit.infinite(),
        intervalPeriod: TransactionPeriodicity.day),
    const RecurrencyData.withLimit(
        ruleRecurrentLimit: RuleRecurrentLimit.infinite(),
        intervalPeriod: TransactionPeriodicity.week),
    const RecurrencyData.withLimit(
        ruleRecurrentLimit: RuleRecurrentLimit.infinite(),
        intervalPeriod: TransactionPeriodicity.month),
    const RecurrencyData.withLimit(
        ruleRecurrentLimit: RuleRecurrentLimit.infinite(),
        intervalPeriod: TransactionPeriodicity.year),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(options.length, (index) {
          final radioItem = options[index];

          return RadioListTile(
              value: radioItem,
              title: Text(radioItem.formText),
              groupValue: widget.selectedRecurrentRule,
              onChanged: (value) => Navigator.pop(context, radioItem));
        }),
        if (options.firstWhereOrNull(
                (element) => element == widget.selectedRecurrentRule) ==
            null)
          RadioListTile(
              value: widget.selectedRecurrentRule,
              title: Text(widget.selectedRecurrentRule.formText),
              groupValue: widget.selectedRecurrentRule,
              onChanged: (value) =>
                  Navigator.pop(context, widget.selectedRecurrentRule)),
        RadioListTile(
            value: null,
            title: Text('Personalizado'),
            groupValue: widget.selectedRecurrentRule,
            onChanged: (value) {
              Navigator.push<RecurrencyData>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IntervalSelector()))
                  .then((value) => Navigator.pop(context, value));
            }),
      ],
    );
  }
}
