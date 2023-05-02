import 'package:finlytics/pages/categories/categories_list.dart';
import 'package:finlytics/pages/currencies/currency_manager.dart';
import 'package:finlytics/pages/settings/edit_profile_modal.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:finlytics/services/user-settings/user_settings.service.dart';
import 'package:finlytics/widgets/skeleton.dart';
import 'package:finlytics/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        minVerticalPadding: 8,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    final settingService = context.watch<UserSettingsService>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return EditProfileModal();
                        });
                  },
                  title: Text('Edit profile'),
                  subtitle: FutureBuilder(
                      future: settingService.getSetting(SettingKey.userName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Skeleton(width: 70, height: 12);
                        }

                        return Text(snapshot.data!);
                      }),
                  leading: FutureBuilder(
                      future: context
                          .watch<UserSettingsService>()
                          .getSetting(SettingKey.avatar),
                      builder: (context, snapshot) {
                        return UserAvatar(avatar: snapshot.data);
                      })),
              const SizedBox(height: 12),
              createListSeparator('General settings'),
              createSettingItem(
                  title: 'Categories',
                  subtitle: 'Crea y edita categorias a tu gusto',
                  icon: Icons.sell_outlined,
                  onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CategoriesList(
                                    mode: CategoriesListMode.page)))
                      }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Administrador de divisas',
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
              const SizedBox(height: 22),
              createListSeparator('Data'),
              createSettingItem(
                  title: 'Export',
                  subtitle: 'Export data',
                  icon: Icons.cloud_download_outlined,
                  onTap: () {
                    DbService.instance
                        .downloadDatabaseFile(context)
                        .then((value) {
                      print('EEEEEEEEEEE');
                    }).catchError((err) {
                      print(err);
                    });
                  }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Import Database',
                  subtitle:
                      'Replace your current data with a new database file',
                  icon: Icons.cloud_upload_outlined,
                  onTap: () {
                    DbService.instance.importDatabase().then((value) {
                      print('EEEEEEEEEEE');
                    }).catchError((err) {
                      print(err);
                    });
                  }),
              createListSeparator('Help us'),
              createSettingItem(
                  title: 'Rate us',
                  subtitle: 'Any review is welcome!',
                  icon: Icons.star_rate_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://play.google.com/store/apps/details?id=com.monekin.app');
                  }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Share Finlytics',
                  icon: Icons.share,
                  onTap: () {
                    Share.share(
                        'Monekin! The best personal finance app. Download here: https://play.google.com/store/apps/details?id=com.monekin.app');
                  }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Report bugs, leave suggestions...',
                  icon: Icons.rate_review_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://github.com/enrique-lozano/Monekin/issues/new/choose');
                  }),
              createListSeparator('Project'),
              createSettingItem(
                  title: 'Terms and privacy',
                  subtitle: 'Check licenses and other legal terms of our app',
                  icon: Icons.inventory_outlined,
                  onTap: () async {
                    // TODO
                  }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Collaborators',
                  subtitle: 'All the developers who have made Monekin grow',
                  icon: Icons.group_outlined,
                  onTap: () async {
                    openURL(context,
                        'https://github.com/enrique-lozano/Monekin/graphs/contributors');
                  }),
              const Divider(indent: 70),
              createSettingItem(
                  title: 'Contact us!',
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
