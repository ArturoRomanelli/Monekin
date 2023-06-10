import 'package:drift/drift.dart';
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/presentation/theme.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(
      child: StreamBuilder(
          stream: UserSettingService.instance.getSettings((p0) =>
              p0.settingKey.equalsValue(SettingKey.appLanguage) |
              p0.settingKey.equalsValue(SettingKey.themeMode)),
          builder: (context, snapshot) {
            print('Finding initial user settings...');

            if (snapshot.hasData) {
              final userSettings = snapshot.data!;

              final lang = userSettings
                  .firstWhere(
                      (element) => element.settingKey == SettingKey.appLanguage)
                  .settingValue;

              if (lang != null) {
                print('App language found. Setting the locale to `$lang`...');
                LocaleSettings.setLocaleRaw(lang);
              } else {
                print(
                    'App language found. Setting the user device language...');
                LocaleSettings.useDeviceLocale();
                UserSettingService.instance
                    .setSetting(SettingKey.appLanguage,
                        LocaleSettings.currentLocale.languageTag)
                    .then((value) => null);
              }

              return TranslationProvider(
                  child: MyApp(
                themeMode: ThemeMode.values.byName(userSettings
                    .firstWhere(
                        (element) => element.settingKey == SettingKey.themeMode)
                    .settingValue!),
              ));
            }

            return Container();
          })));
}

class MyApp extends ConsumerWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the language of the Intl in each rebuild of the TranslationProvider:
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: getThemeData(false),
        darkTheme: getThemeData(true),
        themeMode: themeMode,
        home: const TabsPage());
  }
}
