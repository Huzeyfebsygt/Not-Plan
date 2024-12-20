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
    String path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {

      await db.execute(''' 
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT
        )
      ''');
      await db.execute(''' 
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          email TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE plans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,  -- Plan başlığı (gün, hafta, ay vs.)
          content TEXT,  -- Plan içeriği
          date TEXT,  -- Plan tarihi
          time TEXT,  -- Plan saati
          type INTEGER  -- 0: Günlük, 1: Haftalık, 2: Aylık, 3: Yıllık
        )
      ''');
    });
  }
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    var res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }


  Future<void> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert('notes', note, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertPlan(Map<String, dynamic> plan) async {
    final db = await database;
    await db.insert('plans', plan, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<List<Map<String, dynamic>>> getPlans() async {
    final db = await database;
    return await db.query('plans');
  }

  Future<List<Map<String, dynamic>>> getPlansByType(int type) async {
    final db = await database;
    return await db.query(
      'plans',
      where: 'type = ?', 
      whereArgs: [type],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePlan(int id) async {
    final db = await database;
    await db.delete('plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<void> updatePlan(Map<String, dynamic> plan) async {
    final db = await database;
    await db.update(
      'plans',
      plan,
      where: 'id = ?',
      whereArgs: [plan['id']],
    );
  }
}
