import 'package:eng_word_storage/databases/migration_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../models/group.dart';

class DefaultGroups {
  static const int all = 1;
  static const int notSpecified = 2;
}

class DatabaseService {
  final int _databaseVersion = 2;
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<void> initialize() async {
    try {
      await database;
      await initializeDefaultGroups();
    } catch (e) {
      rethrow;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('word_storage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: (db, version) async {
          await MigrationManager.migrate(db, 0, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await MigrationManager.migrate(db, oldVersion, newVersion);
        },
      );

      // 데이터베이스 초기화 완료
      _database = db; // 여기서 _database 설정

      return db;
    } catch (e) {
      rethrow;
    }
  }

  // Word CRUD operations
  Future<Word> createWord(Word word) async {
    final db = await database;
    final wordLength = word.word.length; // 단어 길이 계산

    final id = await db.insert(
      'words',
      {
        ...word.toMap(),
        'word_length': wordLength, // 단어 길이 추가
      },
    );

    return word.copyWith(id: id);
  }

  Future<List<Word>> getAllWords({
    int limit = 300,
    int offset = 0,
    String orderBy = 'created_at DESC',
    List<int>? groupIds,
    String? query,
  }) async {
    final db = await database;

    String sqlQuery = '''
    SELECT w.*, g.name as group_name 
    FROM words w 
    LEFT JOIN groups g ON w.group_id = g.id
    WHERE 1=1
  ''';

    List<dynamic> args = [];

    if (groupIds != null && groupIds.isNotEmpty) {
      sqlQuery +=
          ' AND w.group_id IN (${List.filled(groupIds.length, '?').join(',')})';
      args.addAll(groupIds);
    }

    if (query != null && query.isNotEmpty) {
      sqlQuery += ' AND (w.word LIKE ? OR w.meaning LIKE ?)';
      args.addAll(['%$query%', '%$query%']);
    }

    sqlQuery += ' ORDER BY $orderBy LIMIT ? OFFSET ?';
    args.addAll([limit, offset]);

    final List<Map<String, dynamic>> maps = await db.rawQuery(sqlQuery, args);

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]).copyWith(
        groupName: maps[i]['group_name'] as String?,
      );
    });
  }

  Future<List<Word>> searchWords(
    String query, {
    List<int>? groupIds,
    String orderBy = 'created_at DESC',
  }) async {
    final db = await database;

    String sql = '''
    SELECT w.*, g.name as group_name 
    FROM words w 
    LEFT JOIN groups g ON w.group_id = g.id
    WHERE (w.word LIKE ? OR w.meaning LIKE ?)
  ''';

    List<dynamic> args = ['%$query%', '%$query%'];

    if (groupIds != null && groupIds.isNotEmpty) {
      sql +=
          ' AND w.group_id IN (${List.filled(groupIds.length, '?').join(',')})';
      args.addAll(groupIds);
    }

    sql += ' ORDER BY $orderBy';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]).copyWith(
        groupName: maps[i]['group_name'] as String?,
      );
    });
  }

  Future<Word?> getWord(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Word.fromMap(maps.first);
  }

  Future<int> updateWord(Word word) async {
    final db = await database;
    return db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllWords() async {
    final db = await database;
    await db.delete('words');
  }

  Future<Group> createGroup(Group group) async {
    final db = await database;
    final id = await db.insert('groups', group.toMap());
    return group.copyWith(id: id); // 생성된 id 반영
  }

  Future<List<Group>> getAllGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('groups_with_word_count');
    return List.generate(maps.length, (i) => Group.fromMap(maps[i]));
  }

  Future<Group?> getGroup(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Group.fromMap(maps.first);
  }

  Future<List<Group>> getUserGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'id > ?',
      whereArgs: [DefaultGroups.all],
      orderBy: 'id ASC',
    );

    final groups = List.generate(maps.length, (i) => Group.fromMap(maps[i]));
    return groups;
  }

  Future<Group?> findGroupByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Group.fromMap(maps.first);
  }

  Future<int> updateGroup(Group group) async {
    final db = await database;
    return db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    // 기본 그룹은 삭제 불가
    if (id == DefaultGroups.all || id == DefaultGroups.notSpecified) {
      throw Exception('Cannot delete default groups');
    }

    final db = await database;
    // 그룹이 삭제되면 해당 그룹의 단어들은 Not specified로 이동
    await db.update(
      'words',
      {'group_id': DefaultGroups.notSpecified},
      where: 'group_id = ?',
      whereArgs: [id],
    );

    return await db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllGroups() async {
    final db = await database;
    await db.delete('groups');
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }

  Future<void> initializeDefaultGroups() async {
    try {
      // 에러 처리 추가
      final db = await database;
      final groups = await getAllGroups();

      // All group 생성
      if (!groups.any((g) => g.id == DefaultGroups.all)) {
        await db.insert('groups', {
          'id': DefaultGroups.all,
          'name': 'All',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Not specified group 생성
      if (!groups.any((g) => g.id == DefaultGroups.notSpecified)) {
        await db.insert('groups', {
          'id': DefaultGroups.notSpecified,
          'name': 'Not specified',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Word>> getAllWordsForExport() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }
}
