import 'package:finlytics/app/transactions/widgets/interval_selector_help.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IntervalSelector extends StatefulWidget {
  const IntervalSelector({super.key});

  @override
  State<IntervalSelector> createState() => _IntervalSelectorState();
}

class _IntervalSelectorState extends State<IntervalSelector> {
  final _formKey = GlobalKey<FormState>();

  TransactionPeriodicity intervalPeriod = TransactionPeriodicity.month;
  int? intervalEach = 1;
  int? remainingIterations = 1;
  DateTime endDate = DateTime.now();

  RuleUntilMode ruleUntilMode = RuleUntilMode.infinity;

  Widget buildRadioButton(RuleUntilMode item, Widget title) {
    return RadioListTile(
        value: item,
        groupValue: ruleUntilMode,
        title: title,
        onChanged: (value) {
          setState(() {
            if (value != null) {
              ruleUntilMode = value;
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      persistentFooterButtons: [
        PersistentFooterButton(
            child: FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    Navigator.pop(
                        context,
                        ruleUntilMode == RuleUntilMode.infinity
                            ? RecurrencyData.infinite(
                                intervalPeriod: intervalPeriod,
                                intervalEach: intervalEach)
                            : RecurrencyData.withLimit(
                                ruleRecurrentLimit: RuleRecurrentLimit(
                                    endDate: ruleUntilMode == RuleUntilMode.date
                                        ? endDate
                                        : null,
                                    remainingIterations:
                                        ruleUntilMode == RuleUntilMode.nTimes
                                            ? remainingIterations
                                            : null),
                                intervalPeriod: intervalPeriod,
                                intervalEach: intervalEach));
                  }
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Continuar')))
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 2, 0, 12),
              child: Text("Se repite"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Cada *',
                            helperText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            intervalEach = int.tryParse(value);
                          },
                          keyboardType: TextInputType.number,
                          validator: (value) => fieldValidator(value,
                              validator: ValidatorType.int, isRequired: true),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: DropdownButtonFormField(
                        value: intervalPeriod,
                        decoration: const InputDecoration(
                          labelText: 'Periodicidad *',
                          helperText: '',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                            TransactionPeriodicity.values.length,
                            (index) => DropdownMenuItem(
                                value: TransactionPeriodicity.values[index],
                                child: Text(TransactionPeriodicity
                                    .values[index].name))),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            intervalPeriod = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 0, 12),
              child: Text("Termina"),
            ),
            buildRadioButton(
                RuleUntilMode.infinity, const Text('Para siempre')),
            const Divider(height: 12, indent: 64),
            buildRadioButton(
                RuleUntilMode.date,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: const Text('Hasta el')),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        controller: TextEditingController(
                            text: DateFormat.yMMMMd().add_Hm().format(endDate)),
                        decoration: const InputDecoration(
                            labelText: 'Fecha y hora *',
                            border: OutlineInputBorder(),
                            isDense: true),
                        readOnly: true,
                        enabled: ruleUntilMode == RuleUntilMode.date,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(1700),
                              lastDate: DateTime(2099));

                          if (pickedDate == null) return;

                          setState(() {
                            endDate = pickedDate;
                          });
                        },
                      ),
                    ),
                  ],
                )),
            const Divider(height: 12, indent: 64),
            buildRadioButton(
                RuleUntilMode.nTimes,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: const Text('Tras')),
                    const SizedBox(width: 8),
                    Flexible(
                        child: TextFormField(
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Repeticiones *',
                        border: OutlineInputBorder(),
                      ),
                      enabled: ruleUntilMode == RuleUntilMode.nTimes,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        remainingIterations = int.tryParse(value);
                      },
                      keyboardType: TextInputType.number,
                      validator: (value) => fieldValidator(value,
                          validator: ValidatorType.int,
                          isRequired: ruleUntilMode == RuleUntilMode.nTimes),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}