import 'package:sqflite/sqflite.dart';

abstract class Migration {
  final int version;

  Migration(this.version);

  Future<void> up(Database db);
  Future<void> down(Database db);
}
