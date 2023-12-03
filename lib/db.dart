import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Success {
  final int? id;
  final String title;
  final String subtitle;

  const Success({
    this.id,
    required this.title,
    required this.subtitle,
  });

  Map<String, dynamic> toMap() {
    // Only include the id in the map if it is not null
    return {
      if (id != null) 'id': id,
      'title': title,
      'subtitle': subtitle,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Success{id: $id, title: $title, subtitle: $subtitle}';
  }
}

class SuccessDatabaseService {
  static final SuccessDatabaseService _instance =
      SuccessDatabaseService._internal();
  factory SuccessDatabaseService() => _instance;
  SuccessDatabaseService._internal();

  late Database _database;

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'success_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE successes(id INTEGER PRIMARY KEY, title TEXT, subtitle TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertSuccess(Success success) async {
    await _database.insert(
      'successes',
      success.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Success>> successes() async {
    final List<Map<String, dynamic>> maps = await _database.query('successes');
    return List.generate(maps.length, (i) {
      return Success(
        id: maps[i]['id'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
      );
    });
  }
}
