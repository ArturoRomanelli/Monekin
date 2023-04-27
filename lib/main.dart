import 'package:finlytics/pages/tabs/tabs.page.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/exchangeRates/exchange_rate.service.dart';
import 'package:finlytics/services/filters/date_range_service.dart';
import 'package:finlytics/services/transaction/transaction_service.dart';
import 'package:finlytics/services/user-settings/user_settings.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CurrencyService>(
            create: (context) => CurrencyService(DbService.instance)),
        ChangeNotifierProvider<AccountService>(
            create: (context) => AccountService(DbService.instance)),
        ChangeNotifierProvider<ExchangeRateService>(
            create: (context) => ExchangeRateService(DbService.instance)),
        ChangeNotifierProvider<CategoryService>(
            create: (context) => CategoryService(DbService.instance)),
        ChangeNotifierProvider<DateRangeService>(
            create: (context) => DateRangeService.instance),
        ChangeNotifierProvider<MoneyTransactionService>(
            create: (context) => MoneyTransactionService(DbService.instance)),
        ChangeNotifierProvider<UserSettingsService>(
            create: (context) => UserSettingsService(DbService.instance)),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          dividerTheme: const DividerThemeData(space: 0),
          colorSchemeSeed: const Color.fromARGB(255, 15, 51, 117),
          useMaterial3: true,
          fontFamily: 'Nunito'),
      home: TabsPage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
