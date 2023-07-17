import 'package:finlytics/core/utils/open_external_url.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  Widget buildLinkItem(String title, {required Function() onTap}) {
    return ListTile(
      title: Text(title),
      trailing: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.settings.project.legal)),
      body: Column(
        children: [
          buildLinkItem(
            t.settings.terms_of_use.title,
            onTap: () {
              openExternalURL(context,
                  'https://github.com/enrique-lozano/Monekin/blob/main/docs/TERMS_OF_USE.md');
            },
          ),
          buildLinkItem(
            t.settings.privacy.title,
            onTap: () {
              openExternalURL(context,
                  'https://github.com/enrique-lozano/Monekin/blob/main/docs/PRIVACY_POLICY.md');
            },
          ),
          buildLinkItem(
            t.settings.licenses.title,
            onTap: () {
              showLicensePage(context: context);
            },
          ),
        ],
      ),
    );
  }
}
