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
        // Create the 'categories' table
        db.execute(
          '''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          );
          '''
        );
        // Create the 'records' table
        db.execute(
          '''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            serial_number INTEGER,
            name TEXT,
            category TEXT,
            description TEXT
          );
          '''
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

  Future<void> insertRecord(String name, String category, String description) async {
    final db = await database;
    await db.insert(
      'records',
      {
        'name': name,
        'category': category,
        'description': description,
      },
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

  Future<List<Map<String, dynamic>>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records');
    return maps;
  }

  Future<List<Map<String, dynamic>>> getFilteredRecords({
    String? filterValue1,
    String? filterValue2,
  }) async {
    final db = await database;

    // 创建筛选条件和参数列表
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    // 如果提供了筛选值1且不为"全部"，则添加模糊匹配条件
    if (filterValue1 != null && filterValue1.isNotEmpty) {
      whereClauses.add('category LIKE ?');
      whereArgs.add('%$filterValue1%');
    }

    // 如果提供了筛选值2，则添加模糊匹配条件
    if (filterValue2 != null && filterValue2.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$filterValue2%');
    }

    // 将筛选条件用 'AND' 连接
    String whereStatement = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

    // 查询数据库
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: whereStatement.isNotEmpty ? whereStatement : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return maps;
  }


  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCategories() async {
    final db = await database;
    await db.delete('categories');
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      'records',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete('records');
  }
}
