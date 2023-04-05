import 'package:finlytics/pages/accounts/accountForm.dart';
import 'package:finlytics/pages/settings/settings.page.dart';
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
  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.business,
      'label': 'Business',
    },
    {
      'icon': Icons.school,
      'label': 'School',
    },
    {
      'icon': Icons.settings_outlined,
      'label': 'Settings',
      'route': const SettingsPage()
    },
  ];

  Widget accountItemInSwiper(Account account) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: /* Container(
              height: 28,
              width: 28,
              child: SvgPicture.asset(
                'lib/assets/icons/currency_flags/bbva-2019.svg',
                fit: BoxFit.contain,
              ), */

                Icon(
              Icons.wallet_giftcard,
              size: 28,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(account.name, style: const TextStyle(fontSize: 16)),
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

  Widget accountList(List<Account>? accounts) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: (accounts?.length ?? 0) + 1,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(left: index == 0 ? 12 : 2),
          width: 250.0,
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async => {
                await Future.delayed(const Duration(milliseconds: 200)),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountFormPage(
                            accountUUID: (index == (accounts?.length ?? 0))
                                ? null
                                : accounts![index].id)))
              },
              child: (index == (accounts?.length ?? 0))
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                          Icon(Icons.add),
                          Text("Create account"),
                        ])
                  : accountItemInSwiper(accounts![index]),
            ),
          ),
        );
      },
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountFormPage()))
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
                                future: context
                                    .watch<AccountService>()
                                    .getAccounts(),
                                builder: (context, accounts) {
                                  if (!accounts.hasData) {
                                    return const LinearProgressIndicator();
                                  } else {
                                    return accountList(accounts.data);
                                  }
                                }),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.all(16),
                              child: Text("Tools",
                                  style: const TextStyle(fontSize: 18))),
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _tools.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = _tools[index];

                              return ListTile(
                                title: Text(item["label"]),
                                leading: Icon(
                                  item["icon"],
                                  color: Theme.of(context).primaryColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => item["route"]))
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
