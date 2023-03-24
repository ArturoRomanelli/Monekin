import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/isoCurrencyCodes.dart';
import 'package:flutter/material.dart';

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
  var _currency = IsoCurrencyCodes.USD;

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
        padding: EdgeInsets.all(16),
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
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter initial value',
                ),
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
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter account icon',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account icon';
                  }
                  return null;
                },
                onSaved: (value) {
                  _icon = value!;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(hintText: 'Enter account currency'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account currency';
                  }
                  if (!IsoCurrencyCodes.values
                      .map((e) => e.toString())
                      .contains('IsoCurrencyCodes.$value')) {
                    return 'Please enter a valid currency code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _currency = convertToEnum(value!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
