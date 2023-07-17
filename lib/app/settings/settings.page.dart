import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/currencies/currency_manager.dart';
import 'package:finlytics/app/settings/advanced_settings_page.dart';
import 'package:finlytics/app/settings/edit_profile_modal.dart';
import 'package:finlytics/app/settings/export_page.dart';
import 'package:finlytics/app/settings/import_page.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/user_avatar.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ListTile createSettingItem(
      {required String title,
      String? subtitle,
      required IconData icon,
      required Function() onTap}) {
    return ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        trailing: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: () => onTap());
  }

  Widget createListSeparator(String title) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Text(title, style: const TextStyle(fontSize: 14)));
  }

  Future<void> openURL(BuildContext context, String urlToOpen) async {
    final Uri url = Uri.parse(urlToOpen);

    final messager = ScaffoldMessenger.of(context);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      messager
          .showSnackBar(const SnackBar(content: Text('Could not launch url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    final settingService = UserSettingService.instance;

    return Scaffold(
        appBar: AppBar(
          title: Text(t.settings.title),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (context) {
                          return const EditProfileModal();
                        });
                  },
                  title: Text(t.settings.edit_profile),
                  subtitle: StreamBuilder(
                      stream: settingService.getSetting(SettingKey.userName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Skeleton(width: 70, height: 12);
                        }

                        return Text(snapshot.data!);
                      }),
                  leading: StreamBuilder(
                      stream: UserSettingService.instance
                          .getSetting(SettingKey.avatar),
                      builder: (context, snapshot) {
                        return UserAvatar(avatar: snapshot.data);
                      })),
              const SizedBox(height: 12),
              createListSeparator(t.settings.general.display),
              createSettingItem(
                  title: t.general.categories,
                  subtitle: t.settings.general.categories_descr,
                  icon: Icons.sell_outlined,
                  onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CategoriesList(
                                    mode: CategoriesListMode.page)))
                      }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.currencies.currency_manager,
                  subtitle:
                      'Configura tu divisa y sus tipos de cambio con otras',
                  icon: Icons.currency_exchange,
                  onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CurrencyManagerPage()))
                      }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.general.other,
                  subtitle: t.settings.general.other_descr,
                  icon: Icons.build_outlined,
                  onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdvancedSettingsPage()))
                      }),
              const SizedBox(height: 22),
              createListSeparator(t.settings.data.display),
              createSettingItem(
                  title: 'Export',
                  subtitle: t.settings.data.export_descr,
                  icon: Icons.cloud_download_outlined,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExportDataPage()));
                  }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.data.import,
                  subtitle: t.settings.data.import_descr,
                  icon: Icons.cloud_upload_outlined,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ImportPage()));
                  }),
              const SizedBox(height: 22),
              createListSeparator(t.settings.help_us.display),
              createSettingItem(
                  title: t.settings.help_us.rate_us,
                  subtitle: t.settings.help_us.rate_us_descr,
                  icon: Icons.star_rate_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://play.google.com/store/apps/details?id=com.monekin.app');
                  }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.help_us.share,
                  icon: Icons.share,
                  onTap: () {
                    Share.share(
                        'Monekin! The best personal finance app. Download here: https://play.google.com/store/apps/details?id=com.monekin.app');
                  }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.help_us.report,
                  icon: Icons.rate_review_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://github.com/enrique-lozano/Monekin/issues/new/choose');
                  }),
              const SizedBox(height: 22),
              createListSeparator('Project'),
              createSettingItem(
                  title: t.settings.project.legal,
                  subtitle: t.settings.project.legal_descr,
                  icon: Icons.inventory_outlined,
                  onTap: () async {
                    // TODO
                  }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.project.contributors,
                  subtitle: t.settings.project.contributors_descr,
                  icon: Icons.group_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://github.com/enrique-lozano/Monekin/graphs/contributors');
                  }),
              const Divider(indent: 54),
              createSettingItem(
                  title: t.settings.project.contact,
                  icon: Icons.email_outlined,
                  onTap: () async {
                    openURL(context, 'mailto:lozin.technologies@gmail.com');
                  }),
              const SizedBox(height: 20)
            ],
          ),
        ));
  }
}
