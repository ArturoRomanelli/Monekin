import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/utils/get_download_path.dart';
import 'package:flutter/material.dart';

class BackupDatabaseService {
  DatabaseImpl db = DatabaseImpl.instance;

  Future<void> downloadDatabaseFile(BuildContext context) async {
    final messeger = ScaffoldMessenger.of(context);

    List<int> dbFileInBytes = await File(await db.databasePath).readAsBytes();

    String downloadPath = await getDownloadPath();
    downloadPath = '${downloadPath}finlytics.db';

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsBytes(dbFileInBytes);

    messeger.showSnackBar(SnackBar(
        content: Text('Base de datos descargada con exito en $downloadPath')));
  }

  Future<void> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // Delete the previous database
      String path = await db.databasePath;

      await file.writeAsString('');

      // Load the new database
      await file.copy(path);
    }
  }
}
