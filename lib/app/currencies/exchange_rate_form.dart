import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/database/services/exchange-rate/exchange_rate_service.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:finlytics/core/models/exchange-rate/exchange_rate.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:finlytics/core/presentation/widgets/currency_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/utils/date_time_picker.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ExchangeRateFormDialog extends StatefulWidget {
  const ExchangeRateFormDialog(
      {super.key,
      this.preSelectedCurrency,
      this.preSelectedDate,
      this.preSelectedRate});

  final Currency? preSelectedCurrency;
  final DateTime? preSelectedDate;
  final double? preSelectedRate;

  @override
  State<ExchangeRateFormDialog> createState() => _ExchangeRateFormDialogState();
}

class _ExchangeRateFormDialogState extends State<ExchangeRateFormDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController rateController = TextEditingController();

  DateTime date = DateTime.now();

  Currency? _currency;

  Currency? userPreferredCurrency;

  @override
  void initState() {
    super.initState();

    rateController.text =
        widget.preSelectedRate == null ? '' : widget.preSelectedRate.toString();

    setState(() {
      _currency = widget.preSelectedCurrency;

      if (widget.preSelectedDate != null) {
        date = widget.preSelectedDate!;
      }
    });

    CurrencyService.instance.getUserPreferredCurrency().then((value) {
      userPreferredCurrency = value;
    });
  }

  onSubmitted() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    ExchangeRateService.instance
        .insertOrUpdateExchangeRate(ExchangeRate(
            currency: _currency!,
            date: date,
            exchangeRate: double.parse(rateController.text)))
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de cambio creado con exito')));
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }).whenComplete(() => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHeader(),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create exchange rate',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                              controller: TextEditingController(
                                  text: _currency != null
                                      ? _currency?.name
                                      : 'Sin especificar'),
                              readOnly: true,
                              validator: (value) {
                                if (_currency == null) {
                                  return 'Please specify a currency';
                                } else if (_currency!.code ==
                                    userPreferredCurrency?.code) {
                                  return 'The currency can not be equal to the user currency';
                                }

                                return null;
                              },
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return CurrencySelectorModal(
                                          preselectedCurrency: _currency,
                                          onCurrencySelected: (newCurrency) => {
                                                setState(() {
                                                  _currency = newCurrency;
                                                })
                                              });
                                    });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Currency',
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(10),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: _currency != null
                                        ? SvgPicture.asset(
                                            'assets/icons/currency_flags/${_currency!.code.toLowerCase()}.svg',
                                            height: 25,
                                            width: 25,
                                          )
                                        : const Skeleton(width: 28, height: 28),
                                  ))),
                          const SizedBox(height: 22),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: TextEditingController(
                                      text: DateFormat.yMMMd().format(
                                          date)), //editing controller of this TextField
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha *',
                                  ),
                                  readOnly:
                                      true, //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate =
                                        await openDateTimePicker(context,
                                            showTimePickerAfterDate: false,
                                            initialDate: date);

                                    if (pickedDate == null) return;

                                    setState(() {
                                      date = pickedDate;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: rateController,
                                  validator: (value) => fieldValidator(value,
                                      validator: ValidatorType.double,
                                      isRequired: true),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de cambio *',
                                    hintText: 'Ex.: 2.14',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              BottomSheetFooter(onSaved: () => onSubmitted())
            ]),
      ),
    );
  }
}
