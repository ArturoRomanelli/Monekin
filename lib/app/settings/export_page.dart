import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/database/backup/backup_database_service.dart';

enum _ExportFormats { csv, db }

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  _ExportFormats selectedExportFormat = _ExportFormats.db;

  Widget cardSelector({
    required _ExportFormats exportFormat,
    required String title,
    required String descr,
    required String iconName,
  }) {
    final isSelected = selectedExportFormat == exportFormat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            width: 1.25,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => setState(() {
            selectedExportFormat = exportFormat;
          }),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/backup/$iconName.svg',
                  height: 36,
                  width: 36,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Text(
                  descr,
                  softWrap: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(t.backup.export.title),
        ),
        persistentFooterButtons: [
          PersistentFooterButton(
              child: FilledButton(
            child: Text(t.backup.export.title),
            onPressed: () async {
              final messeger = ScaffoldMessenger.of(context);

              if (selectedExportFormat == _ExportFormats.db) {
                await BackupDatabaseService()
                    .downloadDatabaseFile(context)
                    .then((value) {
                  print('EEEEEEEEEEE');
                }).catchError((err) {
                  print(err);
                });
              } else {
                await BackupDatabaseService()
                    .exportSpreadsheet(
                        context,
                        await TransactionService.instance
                            .getTransactions()
                            .first)
                    .then((value) {
                  messeger.showSnackBar(SnackBar(
                    content: Text('Fichero descargado con exito en $value'),
                  ));
                }).catchError((err) {
                  messeger.showSnackBar(SnackBar(
                    content: Text('$err'),
                  ));
                });
              }
            },
          ))
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Column(
            children: [
              cardSelector(
                exportFormat: _ExportFormats.db,
                title: t.backup.export.all,
                descr: t.backup.export.all_descr,
                iconName: 'db',
              ),
              cardSelector(
                exportFormat: _ExportFormats.csv,
                title: t.backup.export.transactions,
                descr: t.backup.export.transactions_descr,
                iconName: 'table_file',
              ),
            ],
          ),
        ));
  }
}
