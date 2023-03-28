import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({Key? key}) : super(key: key);

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();

  var _name = '';
  var _iniValue = 0.0;
  var _type = '';
  var _icon = '';
  var _currency = CurrencyService().getUserDefaultCurrency();

  addAccount() async {
    Account newAccount = Account(
        id: "xkjlcfklhkkdl $_name",
        name: _name,
        iniValue: _iniValue,
        date: DateTime.now(),
        type: _type,
        icon: _icon,
        currency: _currency);

    DbService().insertAccount(newAccount).then((value) => {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TabsPage()),
              (Route<dynamic> route) => false)
        });
  }

  List<Currency> filteredCurrencies = CurrencyService().getCurrencies();

  void showModal(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
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
                            setState(() {
                              filteredCurrencies = CurrencyService()
                                  .searchCurrencies(value, context);
                            });

                            print(filteredCurrencies.toString());
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
                                          'assets/icons/currency_flags/${CurrencyService().getCurrencies()[index].code.toLowerCase()}.svg',
                                          height: 35,
                                          width: 35,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _currency = CurrencyService()
                                            .getCurrencies()[index];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Create Account"),
          elevation: 2,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  addAccount();
                }
              },
            ),
          ]),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
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
                onSaved: (value) {
                  _name = value!;
                },
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
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
                onSaved: (value) {
                  _iniValue = double.parse(value!);
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
