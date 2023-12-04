import 'dart:async';

import 'package:layout_tutorial/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Success {
  final int? id;
  final String title;
  final String subtitle;
  final DateTime? created;
  final DateTime? modified;

  const Success({
    this.id,
    required this.title,
    required this.subtitle,
    this.created,
    this.modified,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'subtitle': subtitle,
      if (created != null) 'created': created!.toIso8601String(),
      if (modified != null) 'modified': modified!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Success{id: $id, title: $title, subtitle: $subtitle, created: ${formatDateTime(created)}, modified: ${formatDateTime(modified)}}';
  }
}

class SuccessDatabaseService {
  static final SuccessDatabaseService _instance =
      SuccessDatabaseService._internal();
  factory SuccessDatabaseService() => _instance;
  SuccessDatabaseService._internal();

  late Database _database;

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE successes ADD COLUMN created TEXT');
      await db.execute('ALTER TABLE successes ADD COLUMN modified TEXT');

      // Optionally, set default values for existing rows
      var now = DateTime.now().toIso8601String();
      await db.rawUpdate(
          'UPDATE successes SET created = ?, modified = ?', [now, now]);
    }
    // Implement further migrations if newVersion > 2
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'success_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE successes(id INTEGER PRIMARY KEY, title TEXT, subtitle TEXT, created TEXT, modified TEXT)',
        );
      },
      onUpgrade: _onUpgrade,
      version: 2,
    );
  }

  Future<void> deleteSuccess(int id) async {
    await _database.delete(
      'successes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertSuccess(Success success) async {
    var now = DateTime.now();
    var successToInsert = Success(
      title: success.title,
      subtitle: success.subtitle,
      created: now,
      modified: now,
    );

    await _database.insert(
      'successes',
      successToInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Success>> successes({required DateTime filterCreatedDate}) async {
    // Start of the given day
    DateTime startDate = DateTime(
        filterCreatedDate.year, filterCreatedDate.month, filterCreatedDate.day);
    // Start of the next day
    DateTime endDate = DateTime(filterCreatedDate.year, filterCreatedDate.month,
        filterCreatedDate.day + 1);

    final List<Map<String, dynamic>> maps = await _database.query(
      'successes',
      where: 'created >= ? AND created < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      DateTime? created = maps[i]['created'] != null
          ? DateTime.parse(maps[i]['created'])
          : null;
      DateTime? modified = maps[i]['modified'] != null
          ? DateTime.parse(maps[i]['modified'])
          : null;

      return Success(
        id: maps[i]['id'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        created: created,
        modified: modified,
      );
    });
  }
}
