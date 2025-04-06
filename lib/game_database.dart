import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GameDatabase {
  static final GameDatabase instance = GameDatabase.init();
  static Database? _database;

  GameDatabase.init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'game_history.db');
    _database = await openDatabase(path, version: 1, onCreate: createDB);
    return _database!;
  }

  Future createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        moves TEXT,
        winner TEXT
      )
    ''');
  }

  Future<int> insertGame({
    required List<String> moves,
    required String winner,
  }) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('game_history', {
      'date': now,
      'moves': jsonEncode(moves),
      'winner': winner,
    });
  }

  Future<List<Map<String, dynamic>>> getGames() async {
    final db = await instance.database;
    return await db.query('game_history', orderBy: 'date DESC');
  }
}
