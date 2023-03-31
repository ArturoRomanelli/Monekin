import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
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
  var _icon = '';
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
            }));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iniValueController.dispose();
    super.dispose();
  }

  void showModal(BuildContext context) {
    final currencyService = context.read<CurrencyService>();

    List<Currency> filteredCurrencies = currencyService.getCurrencies();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.8,
              minChildSize: 0.4,
              initialChildSize: 0.8,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("Selecciona una moneda"),
                      elevation: 5,
                    ),
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search by name or currency code',
                              labelText: "Search currency",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setSheetState(() {
                                filteredCurrencies = currencyService
                                    .searchCurrencies(value, context);
                              });
                            },
                          ),
                        ),
                        Expanded(
                            child: ListView.separated(
                                controller: scrollController,
                                itemCount: filteredCurrencies.length,
                                separatorBuilder: (context, i) {
                                  return const Divider();
                                },
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      child: ListTile(
                                        title: Text(filteredCurrencies[index]
                                            .getLocaleName(context)),
                                        leading: Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/icons/currency_flags/${filteredCurrencies[index].code.toLowerCase()}.svg',
                                            height: 35,
                                            width: 35,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _currency = filteredCurrencies[index];
                                        });
                                        Navigator.of(context).pop();
                                      });
                                })),
                      ],
                    ),
                  ),
                );
              },
            );
          });
        });
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Hola",
                        hintText: 'Enter account name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account name';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      controller: _iniValueController,
                      decoration: const InputDecoration(
                        hintText: 'Enter initial value',
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
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter account type',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account type';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _type = value!;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Enter account icon',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_alarm)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account icon';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _icon = value!;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextField(
                        controller: TextEditingController(
                            text: _currency.getLocaleName(context)),
                        readOnly: true,
                        onTap: () => showModal(context),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Read-only field',
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/currency_flags/${_currency.code.toLowerCase()}.svg',
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
