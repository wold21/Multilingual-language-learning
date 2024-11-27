import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../models/group.dart';

class DefaultGroups {
  static const int all = 1;
  static const int notSpecified = 2;
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<void> initialize() async {
    await database; // 데이터베이스 초기화
    await initializeDefaultGroups(); // 기본 그룹 생성
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('word_storage.db');
    return _database!;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 버전 1에서 2로 업그레이드
      // word_length 컬럼 추가
      await db.execute('ALTER TABLE words ADD COLUMN word_length INTEGER');

      // 기존 데이터의 word_length 업데이트
      await db.execute('UPDATE words SET word_length = length(word)');
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      print('Initializing database at path: $path');

      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );

      // 데이터베이스 초기화 완료
      _database = db; // 여기서 _database 설정

      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
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

  Future<Group> createGroup(Group group) async {
    final db = await database;
    final id = await db.insert('groups', group.toMap());
    return group.copyWith(id: id); // 생성된 id 반영
  }

  Future<List<Group>> getAllGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('groups');
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
    print('Getting user groups...'); // 메서드 호출 확인
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'id > ?',
      whereArgs: [DefaultGroups.all],
      orderBy: 'id ASC',
    );
    print('Database query result: $maps'); // DB 쿼리 결과 확인

    final groups = List.generate(maps.length, (i) => Group.fromMap(maps[i]));
    print('Converted groups: $groups'); // 변환된 그룹 객체 확인
    return groups;
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

      print('Existing groups: $groups'); // 디버깅용 로그

      // All group 생성
      if (!groups.any((g) => g.id == DefaultGroups.all)) {
        print('Creating All group...'); // 디버깅용 로그
        await db.insert('groups', {
          'id': DefaultGroups.all,
          'name': 'All',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Not specified group 생성
      if (!groups.any((g) => g.id == DefaultGroups.notSpecified)) {
        print('Creating Not specified group...'); // 디버깅용 로그
        await db.insert('groups', {
          'id': DefaultGroups.notSpecified,
          'name': 'Not specified',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      print('Error initializing default groups: $e'); // 에러 로그
      rethrow;
    }
  }
}
