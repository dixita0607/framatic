import 'dart:async';

import 'package:framatic/core/models/frame.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FramaticDB {
  static final FramaticDB _instance = FramaticDB._();
  late Database _db;
  var _isInitialized = false;

  FramaticDB._();
  factory FramaticDB() => _instance;

  static FramaticDB get instance => _instance;
  Database get db {
    if (_isInitialized == false) {
      throw StateError(
        'Database connection is not open. Call open() method first to access the db instance',
      );
    }
    return _db;
  }

  Future<String> _getDbPath() async =>
      join(await getDatabasesPath(), DBSchemaValues.fileName);

  Future<void> open() async {
    if (_isInitialized == true) return;
    final dbPath = await _getDbPath();
    _db = await openDatabase(
      dbPath,
      version: DBSchemaValues.dbVersion,
      onCreate: _createDatabase,
    );
    _isInitialized = true;
  }

  FutureOr<void> _createDatabase(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${FramesTable.name} (
            ${FramesTable.id} ${DBTypes.integer} primary key autoincrement,
            ${FramesTable.title} ${DBTypes.text} not null,
            ${FramesTable.width} ${DBTypes.integer} not null,
            ${FramesTable.height} ${DBTypes.integer} not null,
            ${FramesTable.isCustom} ${DBTypes.integer} not null
          )
        ''');

    await db.insert(
      FramesTable.name,
      Frame(title: '16:9', width: 16, height: 9, isCustom: false).toJson(),
    );
    await db.insert(
      FramesTable.name,
      Frame(title: '4:3', width: 4, height: 3, isCustom: false).toJson(),
    );
    await db.insert(
      FramesTable.name,
      Frame(title: '1:1', width: 1, height: 1, isCustom: false).toJson(),
    );
  }

  Future<void> close() async => await _db.close();
}

abstract class DBTypes {
  static const String integer = 'INTEGER';
  static const String real = 'REAL';
  static const String text = 'TEXT';
  static const String blob = 'BLOB';
}

abstract class DBSchemaValues {
  static const String fileName = 'framatic.db';
  static const String dbName = 'Framatic';
  static const int dbVersion = 1;
}
