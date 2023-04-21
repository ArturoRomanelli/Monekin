import 'package:finlytics/pages/categories/categories_list.dart';
import 'package:finlytics/pages/currencies/currency_manager.dart';
import 'package:finlytics/services/db/db.service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ListTile createSettingItem(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Function() onTap}) {
    return ListTile(
        minVerticalPadding: 8,
        title: Text(title),
        subtitle: Text(subtitle),
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
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),
          ],
        ),
        onTap: () => onTap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: const Text('General settings',
                    style: TextStyle(fontSize: 14))),
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
                subtitle: 'Configura tu divisa y sus tipos de cambio con otras',
                icon: Icons.currency_exchange,
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CurrencyManagerPage()))
                    }),
            const SizedBox(height: 22),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: const Text('Data', style: TextStyle(fontSize: 14))),
            createSettingItem(
                title: 'Export',
                subtitle: 'Export data',
                icon: Icons.cloud_download_outlined,
                onTap: () => {
                      DbService.instance
                          .downloadDatabaseFile(context)
                          .then((value) {
                        print('EEEEEEEEEEE');
                      }).catchError((err) {
                        print(err);
                      })
                    }),
            const Divider(indent: 70)
          ],
        ));
  }
}
