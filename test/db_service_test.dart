import 'package:finlytics/core/database/db.service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DbService', () {
    late DbService dbService;

    setUp(() {
      dbService = DbService.instance;
    });

    test('Database should be initialized', () async {
      expect(await dbService.initDatabase(), isNotNull);
    });

    test('Database should be opened', () async {
      expect(await dbService.database, isNotNull);
    });
  });
}
