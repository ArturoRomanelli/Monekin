import 'package:finlytics/pages/categories/categories_list.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: const Text("General settings",
                    style: TextStyle(fontSize: 14))),
            ListTile(
              title: Text("Categories"),
              subtitle: Text("Crea y edita categorias a tu gusto"),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sell_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CategoriesList()))
              },
            ),
            Container(
              margin: EdgeInsets.only(left: 56),
              child: Divider(
                height: 0,
              ),
            )
          ],
        ));
  }
}
