import 'package:cyber_jacket/templates/template.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class Database {
  Future<sqflite.Database?>? _database;
  static const _tableName = 'templates';
  static final instance = Database._internal();

  Database._internal();

  Future<void> init() async {
    // Open the database and store the reference.
    _database = sqflite.openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await sqflite.getDatabasesPath(), 'templates_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, bytes BLOB)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  // Define a function that inserts dogs into the database
  Future<void> insertTemplate(Template template) async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db?.insert(
      _tableName,
      template.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTemplate(int id) async {
    final db = await _database;

    await db?.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await _database;

    final List<Map<String, dynamic>>? maps = await db?.query(_tableName);

    if (maps != null) {
      return List.generate(maps.length, (i) {
        return Template.fromMap(maps[i]);
      });
    } else {
      return [];
    }
  }
}
