import 'package:eng_word_storage/databases/migration_base.dart';
import 'package:sqflite/sqflite.dart';

class V1 extends Migration {
  V1() : super(1);

  @override
  Future<void> up(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE words(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      word TEXT NOT NULL,
      word_length INTEGER NOT NULL, 
      meaning TEXT NOT NULL,
      memo TEXT,
      group_id INTEGER,
      language TEXT NOT NULL,
      audio_path TEXT,
      audio_last_updated INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (group_id) REFERENCES groups (id)
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_word_length ON words(word_length)
  ''');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS words');
    await db.execute('DROP TABLE IF EXISTS groups');
    await db.execute('''
      DROP INDEX IF EXISTS idx_word_length
    ''');
  }
}
