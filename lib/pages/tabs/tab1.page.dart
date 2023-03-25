import 'package:finlytics/pages/accounts/accountForm.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';

class Tab1Page extends StatefulWidget {
  const Tab1Page({Key? key}) : super(key: key);

  @override
  State<Tab1Page> createState() => _Tab1PageState();
}

class _Tab1PageState extends State<Tab1Page> {
  List<Account>? accounts;

  @override
  void initState() {
    DbService().getAccounts().then((value) => setState(() {
          accounts = value;
          print(accounts.toString());
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello Tab 1"),
      ),
      body: SizedBox(
        height: 100,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: (accounts?.length ?? 0) + 1,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 160.0,
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountFormPage()))
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (index == (accounts?.length ?? 0))
                                  ? const <Widget>[
                                      Icon(Icons.add),
                                      Text("Create account"),
                                    ]
                                  : <Widget>[
                                      Text(accounts![index].name),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
