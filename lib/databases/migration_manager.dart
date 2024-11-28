import 'package:eng_word_storage/databases/migration/v1.dart';
import 'package:eng_word_storage/databases/migration/v2.dart';
import 'package:eng_word_storage/databases/migration_base.dart';
import 'package:sqflite/sqflite.dart';

class MigrationManager {
  static final List<Migration> migrations = [
    V1(),
    V2(),
  ];

  static Future<void> migrate(
      Database db, int oldVersion, int newVersion) async {
    try {
      for (var migration in migrations) {
        if (migration.version > oldVersion && migration.version <= newVersion) {
          await migration.up(db);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
