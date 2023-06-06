import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.general.other),
      ),
      body: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text("Language")),
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  items: const [
                    DropdownMenuItem(value: "es", child: Text('ES')),
                    DropdownMenuItem(value: "en", child: Text('EN'))
                  ],
                  value: LocaleSettings.currentLocale.languageTag,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    if (value == null) return;

                    LocaleSettings.setLocaleRaw(value,
                        listenToDeviceLocale: true);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
