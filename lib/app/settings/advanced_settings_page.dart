import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  Widget buildSelector(
      {required String title, required DropdownButton dropdown}) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title)),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: dropdown,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.general.other),
      ),
      body: Column(
        children: [
          buildSelector(
              title: t.settings.lang,
              dropdown: DropdownButton(
                items: [
                  DropdownMenuItem(value: 'es', child: Text(t.lang.es)),
                  DropdownMenuItem(value: 'en', child: Text(t.lang.en))
                ],
                value: LocaleSettings.currentLocale.languageTag,
                underline: const SizedBox(),
                onChanged: (value) {
                  if (value == null) return;

                  LocaleSettings.setLocaleRaw(value,
                      listenToDeviceLocale: true);

                  UserSettingService.instance
                      .setSetting(SettingKey.appLanguage, value)
                      .then((value) => null);
                },
              )),
          const Divider(),
          StreamBuilder(
              stream:
                  UserSettingService.instance.getSetting(SettingKey.themeMode),
              builder: (context, snapshot) {
                return buildSelector(
                    title: 'Theme',
                    dropdown: DropdownButton(
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text('Auto')),
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark'))
                      ],
                      value: snapshot.data ?? 'system',
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value == null) return;

                        UserSettingService.instance
                            .setSetting(SettingKey.themeMode, value)
                            .then((value) => null);
                      },
                    ));
              }),
        ],
      ),
    );
  }
}
