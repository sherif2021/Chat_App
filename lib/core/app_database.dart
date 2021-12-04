import 'package:chat/utility/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> getInstance() async {
    if (_db == null)
      _db = await openDatabase(join(await getDatabasesPath(), 'main.db'),
          version: 1,
          onCreate: _onCreate,
          onUpgrade: _onUpgradeAndDowngrade,
          onDowngrade: _onUpgradeAndDowngrade);
    return _db!;
  }

  static void _onCreate(Database database, int version) async {
    print('database created');
    final batch = database.batch();
    batch
      ..execute(
          'CREATE TABLE $messageTable(i INTEGER PRIMARY KEY AUTOINCREMENT, id VARCHAR(255), uid VARCHAR(255), text TEXT, attach TEXT, me INTEGER, sent INTEGER, seen INTEGER, time INTEGER)')
      ..execute(
          'CREATE TABLE $userTable(i INTEGER PRIMARY KEY AUTOINCREMENT, uid VARCHAR(255), name VARCHAR(255), pic TEXT, lastSeen INTEGER)');
    await batch.commit();
  }

  static void _onUpgradeAndDowngrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $messageTable');
    await db.execute('DROP TABLE IF EXISTS $userTable');
    _onCreate(db, newVersion);
  }
}
