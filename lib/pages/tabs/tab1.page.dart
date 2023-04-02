import 'package:finlytics/pages/accounts/accountForm.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Tab1Page extends StatefulWidget {
  const Tab1Page({Key? key}) : super(key: key);

  @override
  State<Tab1Page> createState() => _Tab1PageState();
}

class _Tab1PageState extends State<Tab1Page> {
  Widget accountItemInSwiper(Account account) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).primaryColorLight),
            child: Icon(
              Icons.access_alarm,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(account.name, style: const TextStyle(fontSize: 18)),
                Text(NumberFormat.simpleCurrency(
                        locale: "es",
                        decimalDigits: 0,
                        name: account.currency.code)
                    .format(account.iniValue)),
              ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Good evening,",
                                  style: TextStyle(fontSize: 12)),
                              Text("user", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const Text("Hello")
                        ]),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total balance",
                            style: TextStyle(fontSize: 12)),
                        Text("287287",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .fontSize)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("My accounts"),
                    TextButton(
                      child: const Text("See all"),
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      onPressed: () async => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AccountFormPage()))
                      },
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FutureBuilder(
                            future:
                                context.watch<AccountService>().getAccounts(),
                            builder: (context, accounts) {
                              if (!accounts.hasData) {
                                return const LinearProgressIndicator();
                              } else {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: (accounts.data?.length ?? 0) + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          left: index == 0 ? 12 : 2),
                                      width: 250.0,
                                      child: Card(
                                        elevation: 2,
                                        clipBehavior: Clip.antiAlias,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () async => {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200)),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AccountFormPage(
                                                              accountUUID: (index ==
                                                                      (accounts
                                                                              .data
                                                                              ?.length ??
                                                                          0))
                                                                  ? null
                                                                  : accounts
                                                                      .data![
                                                                          index]
                                                                      .id)))
                                            },
                                            child: (index ==
                                                    (accounts.data?.length ??
                                                        0))
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const <Widget>[
                                                        Icon(Icons.add),
                                                        Text("Create account"),
                                                      ])
                                                : accountItemInSwiper(
                                                    accounts.data![index]),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }),
                      ),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
