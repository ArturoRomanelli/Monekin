import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CurrencyService>(create: (context) => CurrencyService()),
        ChangeNotifierProvider<AccountService>(
            create: (context) => AccountService(DbService.instance)),
        ChangeNotifierProvider<CategoryService>(
            create: (context) => CategoryService(DbService.instance)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 15, 51, 117),
        useMaterial3: true,
      ),
      home: TabsPage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
