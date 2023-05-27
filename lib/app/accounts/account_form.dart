import 'package:finlytics/app/accounts/account_type_selector.dart';
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/database/services/exchange-rate/exchange_rate_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/currency/currency.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/presentation/widgets/currency_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/expansion_panel/single_expansion_panel.dart';
import 'package:finlytics/core/presentation/widgets/icon_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({Key? key, this.account, this.prevPage})
      : super(key: key);

  /// Account UUID to edit (if any)
  final Account? account;

  final Widget? prevPage;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _swiftController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  AccountType _type = AccountType.normal;
  SupportedIcon _icon = SupportedIconService.instance.defaultSupportedIcon;
  Currency? _currency;

  Account? _accountToEdit;

  DateTime _openingDate = DateTime.now();

  bool showCurrencyExchangesWarn = false;

  getCurrencyExchange(Currency currency) {
    ExchangeRateService.instance
        .getLastExchangeRateOf(currencyCode: currency.code)
        .first
        .then((value) {
      if (value != null) {
        showCurrencyExchangesWarn = false;
      } else {
        showCurrencyExchangesWarn = true;
      }

      setState(() {});
    });
  }

  submitForm() async {
    final accountService = AccountService.instance;

    double newBalance = double.parse(_balanceController.text);

    navigateBack() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => widget.prevPage ?? const TabsPage()),
        (Route<dynamic> route) => false);

    if (_accountToEdit != null) {
      newBalance = _accountToEdit!.iniValue +
          newBalance -
          await accountService.getAccountMoney(account: _accountToEdit!).first;
    }

    Account accountToSubmit = Account(
      id: _accountToEdit?.id ?? const Uuid().v4(),
      name: _nameController.text,
      iniValue: newBalance,
      date: _openingDate,
      type: _type,
      iconId: _icon.id,
      currency: _currency!,
      iban: _ibanController.text.isEmpty ? null : _ibanController.text,
      description: _textController.text.isEmpty ? null : _textController.text,
      swift: _swiftController.text.isEmpty ? null : _swiftController.text,
    );

    if (_accountToEdit != null) {
      await accountService
          .updateAccount(accountToSubmit)
          .then((value) => {navigateBack()});
    } else {
      await accountService
          .insertAccount(accountToSubmit)
          .then((value) => {navigateBack()});
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      _accountToEdit = widget.account;
      _fillForm();
    } else {
      CurrencyService.instance.getUserPreferredCurrency().then((value) {
        setState(() {
          _currency = value;
        });
      });
    }
  }

  void _fillForm() {
    final accountService = AccountService.instance;

    if (_accountToEdit == null) return;

    _nameController.text = _accountToEdit!.name;
    _ibanController.text = _accountToEdit!.iban ?? '';
    _swiftController.text = _accountToEdit!.swift ?? '';
    _textController.text = _accountToEdit!.description ?? '';

    _openingDate = _accountToEdit!.date;

    _type = _accountToEdit!.type;

    accountService
        .getAccountMoney(account: _accountToEdit!)
        .first
        .then((value) {
      _balanceController.text = value.toString();
    });

    _icon = _accountToEdit!.icon;

    CurrencyService.instance
        .getCurrencyByCode(_accountToEdit!.currency.code)
        .first
        .then((value) {
      setState(() {
        _currency = value;
      });
    });

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _textController.dispose();
    _ibanController.dispose();
    _swiftController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        PersistentFooterButton(
          child: FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                submitForm();
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Guardar cuenta'),
          ),
        )
      ],
      appBar: AppBar(
        title: Text(widget.account != null ? 'Edit account' : 'Create Account'),
        elevation: 2,
      ),
      body: widget.account != null && _accountToEdit == null
          ? const LinearProgressIndicator()
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return IconSelectorModal(
                                      preselectedIconID: _icon.id,
                                      onIconSelected: (selectedIcon) {
                                        setState(() {
                                          _icon = selectedIcon;
                                        });
                                      },
                                    );
                                  });
                            },
                            child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.625,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6))),
                                child: _icon.display(size: 48)),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Account name *',
                                hintText: 'Ex.: My account',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  textFieldValidator(value, isRequired: true),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.next,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _balanceController,
                        decoration: InputDecoration(
                          labelText: widget.account != null
                              ? 'Current balance *'
                              : 'Initial balance *',
                          hintText: 'Ex.: 200',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => textFieldValidator(value,
                            isNumber: true, isRequired: true),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                          controller: TextEditingController(
                              text: _currency != null
                                  ? _currency?.name
                                  : 'Sin especificar'),
                          readOnly: true,
                          onTap: () {
                            if (_currency == null) return;

                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CurrencySelectorModal(
                                      preselectedCurrency: _currency!,
                                      onCurrencySelected: (newCurrency) {
                                        setState(() {
                                          _currency = newCurrency;
                                        });

                                        getCurrencyExchange(newCurrency);
                                      });
                                });
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Currency',
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              prefixIcon: _currency != null
                                  ? Container(
                                      margin: const EdgeInsets.all(10),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/icons/currency_flags/${_currency!.code.toLowerCase()}.svg',
                                        height: 25,
                                        width: 25,
                                      ),
                                    )
                                  : null)),
                      const SizedBox(height: 12),
                      if (showCurrencyExchangesWarn)
                        Card(
                          color: Colors.amber[50],
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'No posees información sobre tipos de cambio para esta divisa. Se usará 1.0 como tipo de cambio por defecto. Puedes modificar esto en los ajustes',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_accountToEdit == null) const SizedBox(height: 12),
                      if (_accountToEdit == null)
                        AccountTypeSelector(onSelected: (newType) {
                          setState(() {
                            _type = newType;
                          });
                        }),
                      const SizedBox(height: 16),
                      SingleExpansionPanel(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: TextEditingController(
                                  text: DateFormat.yMMMd()
                                      .add_jm()
                                      .format(_openingDate)),
                              decoration: const InputDecoration(
                                labelText: 'Fecha de apertura *',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _openingDate,
                                    firstDate: DateTime(1700),
                                    lastDate: DateTime(2099));

                                if (pickedDate == null) return;

                                setState(() {
                                  _openingDate = pickedDate;
                                });
                              },
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _ibanController,
                              decoration: const InputDecoration(
                                labelText: 'IBAN',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _swiftController,
                              decoration: const InputDecoration(
                                labelText: 'SWIFT',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              minLines: 2,
                              maxLines: 10,
                              controller: _textController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                hintText:
                                    'Type some notes/description about this account',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 22),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
