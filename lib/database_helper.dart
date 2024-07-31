import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app_data.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertCategory(String name) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
