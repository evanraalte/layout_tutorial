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
  final DateTime? date;

  const Success({
    this.id,
    required this.title,
    required this.subtitle,
    this.created,
    this.modified,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'subtitle': subtitle,
      if (created != null) 'created': created!.toIso8601String(),
      if (modified != null) 'modified': modified!.toIso8601String(),
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Success{id: $id, title: $title, subtitle: $subtitle, created: ${formatDateTime(created)}, modified: ${formatDateTime(modified)}},  date: ${formatDateTime(date)}';
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

    if (oldVersion < 3) {
      // Add the new 'date' column
      await db.execute('ALTER TABLE successes ADD COLUMN date TEXT');

      // Update existing rows to set the 'date' column value from 'created'
      await db.rawUpdate('UPDATE successes SET date = created');
    }
    // Implement further migrations if newVersion > 2
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'success_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE successes(id INTEGER PRIMARY KEY, title TEXT, subtitle TEXT, created TEXT, modified TEXT, date TEXT)',
        );
      },
      onUpgrade: _onUpgrade,
      version: 3,
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
      date: success.date ?? now,
    );

    await _database.insert(
      'successes',
      successToInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSuccess(Success success) async {
    var now = DateTime.now();
    var successToUpdate = Success(
      id: success.id,
      title: success.title,
      subtitle: success.subtitle,
      created: success.created,
      modified: now, // Update the modified time
      date: success.date,
    );

    await _database.update(
      'successes',
      successToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [success.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Success>> getAllSuccesses() async {
    final List<Map<String, dynamic>> maps = await _database.query('successes');

    return List.generate(maps.length, (i) {
      return Success(
        id: maps[i]['id'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        created: maps[i]['created'] != null
            ? DateTime.parse(maps[i]['created'])
            : null,
        modified: maps[i]['modified'] != null
            ? DateTime.parse(maps[i]['modified'])
            : null,
        date: maps[i]['date'] != null ? DateTime.parse(maps[i]['date']) : null,
      );
    });
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
      where: 'date >= ? AND date < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      DateTime? created = maps[i]['created'] != null
          ? DateTime.parse(maps[i]['created'])
          : null;
      DateTime? modified = maps[i]['modified'] != null
          ? DateTime.parse(maps[i]['modified'])
          : null;

      DateTime? date =
          maps[i]['date'] != null ? DateTime.parse(maps[i]['date']) : null;

      return Success(
        id: maps[i]['id'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        created: created,
        modified: modified,
        date: date,
      );
    });
  }
}
