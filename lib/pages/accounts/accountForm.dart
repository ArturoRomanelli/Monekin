import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/widgets/currency_selector_modal.dart';
import 'package:finlytics/widgets/icon_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({Key? key, this.accountUUID}) : super(key: key);

  /// Account UUID to edit (if any)
  final String? accountUUID;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iniValueController = TextEditingController();

  var _type = '';
  var _icon = 'question_mark';
  late Currency _currency;

  Account? _accountToEdit;

  submitForm() async {
    Account accountToSubmit = Account(
        id: _accountToEdit?.id ?? const Uuid().v4(),
        name: _nameController.text,
        iniValue: double.parse(_iniValueController.text),
        date: _accountToEdit?.date ?? DateTime.now(),
        type: _type,
        icon: _icon,
        currency: _currency);

    final navigateBack = Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TabsPage()),
        (Route<dynamic> route) => false);

    if (_accountToEdit != null) {
      context
          .read<AccountService>()
          .updateAccount(accountToSubmit)
          .then((value) => {navigateBack});
    } else {
      context
          .read<AccountService>()
          .insertAccount(accountToSubmit)
          .then((value) => {navigateBack});
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.accountUUID != null) {
      _fillForm();
    }

    _currency = context.read<CurrencyService>().getUserDefaultCurrency();
  }

  void _fillForm() {
    context
        .read<AccountService>()
        .getAccountByID(widget.accountUUID!)
        .then((value) => setState(() {
              _accountToEdit = value;

              if (_accountToEdit == null) return;

              _nameController.text = _accountToEdit!.name;
              _iniValueController.text = _accountToEdit!.iniValue.toString();

              _icon = _accountToEdit!.icon;
            }));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iniValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.accountUUID != null ? "Edit account" : "Create Account"),
          elevation: 2,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  submitForm();
                }
              },
            ),
          ]),
      body: widget.accountUUID != null && _accountToEdit == null
          ? const LinearProgressIndicator()
          : Container(
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
                                    preselectedIcon: _icon,
                                    onIconSelected: (selectedIcon) {
                                      setState(() {
                                        _icon = selectedIcon.id;
                                      });
                                    },
                                  );
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: SvgPicture.asset(
                              SupportedIconService.instance
                                  .getIconByID(_icon)
                                  .urlToAssets,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Account name *",
                              hintText: "Ex.: My account",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter account name';
                              }
                              return null;
                            },
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
                      controller: _iniValueController,
                      decoration: const InputDecoration(
                        labelText: 'Initial balance *',
                        hintText: "Ex.: 200",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter initial value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                        controller: TextEditingController(
                            text: _currency.getLocaleName(context)),
                        readOnly: true,
                        onTap: () => {
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
                                  })
                            },
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Currency',
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SvgPicture.asset(
                                'lib/assets/icons/currency_flags/${_currency.code.toLowerCase()}.svg',
                                height: 25,
                                width: 25,
                              ),
                            ))),
                  ],
                ),
              ),
            ),
    );
  }
}
