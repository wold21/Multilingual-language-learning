import 'package:eng_word_storage/databases/migration_base.dart';
import 'package:sqflite/sqflite.dart';

class V2 extends Migration {
  V2() : super(2);

  @override
  Future<void> up(Database db) async {
    await db.execute('''
  CREATE VIEW IF NOT EXISTS groups_with_word_count AS
  SELECT 
    g.*,
    COALESCE(COUNT(w.id), 0) as word_count
  FROM groups g
  LEFT JOIN words w ON g.id = w.group_id
  GROUP BY g.id
''');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('ALTER TABLE words_temp RENAME TO words');
  }
}
