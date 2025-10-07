import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await initializeDb();
    return _db;
  }

  initializeDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'cooking.db');

    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE 'Cooking' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'title' TEXT NOT NULL UNIQUE,
      'ingredient' TEXT NOT NULL,
      'recipe' TEXT NOT NULL,
      'imagepath' TEXT NOT NULL,
      'type' TEXT NOT NULL
    )
''');
  }

  Future<int?> getLastIDFromDatabase(String sql) async {
    try {
      Database? mydb = await db;
      List<Map> response = await mydb!.rawQuery(sql);
      int lastId = response[0]['MAX(id)'];
      return lastId;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  reaAlldData(String sql) async {
    try {
      Database? mydb = await db;
      var response = await mydb!.rawQuery(sql);
      return response;
    } catch (e) {}
  }

  Future<List<Map>> readData(
      {required String table,
      required String orderby,
      required String where,
      required List<String> whereArgs}) async {
    try {
      Database? mydb = await db;
      List<Map> response = await mydb!.query(
        table,
        orderBy: orderby,
        where: '$where',
        whereArgs: whereArgs,
      );
      return response;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> insertData(String sql) async {
    try {
      Database? mydb = await db;
      int response = await mydb!.rawInsert(sql);
      return response;
    } catch (e) {
      return e.toString();
    }
  }

  updateData(String sql) async {
    try {
      Database? mydb = await db;
      int response = await mydb!.rawUpdate(sql);
      return response;
    } catch (e) {}
  }

  deleteData(String sql) async {
    try {
      Database? mydb = await db;
      int response = await mydb!.rawDelete(sql);
      return response;
    } catch (e) {}
  }

  closeDatabase() async {
    try {
      Database? mydb = await db;
      await mydb!.close();
    } catch (e) {}
  }
}
