import 'package:finlytics/app/settings/import_csv.dart';
import 'package:finlytics/core/database/backup/backup_database_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.backup.import.title),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(t.settings.data.import),
            subtitle: Text(
                "Importa una base de datos anteriormente guardada desde Finlytics. Esta acción remplazará cualquier dato actual de la aplicación por los nuevos datos"),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            minVerticalPadding: 16,
            onTap: () {
              BackupDatabaseService().importDatabase().then((value) {
                print('EEEEEEEEEEE');
              }).catchError((err) {
                print(err);
              });
            },
          ),
          const Divider(),
          ListTile(
            title: Text(t.settings.data.import),
            subtitle: Text(
                "Importa transacciones desde un fichero .csv de forma manual"),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            minVerticalPadding: 16,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImportCSVPage()));
            },
          ),
        ],
      ),
    );
  }
}
