import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/data/frame_service.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('constructor surfaces an unopened database as a domain error', () {
    expect(() => FrameService(), throwsA(isA<DatabaseError>()));
  });

  test('updateFrame rejects predefined frames before writing', () async {
    final db = _FakeDatabase([
      Frame(id: 1, title: '16:9', width: 16, height: 9).toJson(),
    ]);
    final service = FrameService(db: db);

    await expectLater(
      service.updateFrame(Frame(id: 1, title: 'Wide', width: 2, height: 1)),
      throwsA(isA<UpdateFrameError>()),
    );

    expect(db.updateCalls, isEmpty);
  });

  test('deleteFrame rejects predefined frames before writing', () async {
    final db = _FakeDatabase([
      Frame(id: 1, title: '16:9', width: 16, height: 9).toJson(),
    ]);
    final service = FrameService(db: db);

    await expectLater(service.deleteFrame(1), throwsA(isA<DeleteFrameError>()));

    expect(db.deleteCalls, isEmpty);
  });

  test('updateFrame allows custom frames', () async {
    final db = _FakeDatabase([
      Frame(
        id: 2,
        title: 'Custom',
        width: 2,
        height: 1,
        isCustom: true,
      ).toJson(),
    ]);
    final service = FrameService(db: db);

    final updatedFrame = await service.updateFrame(
      Frame(id: 2, title: 'Cinema', width: 21, height: 9, isCustom: true),
    );

    expect(updatedFrame.title, 'Cinema');
    expect(db.updateCalls, [2]);
  });

  test('deleteFrame allows custom frames', () async {
    final db = _FakeDatabase([
      Frame(
        id: 2,
        title: 'Custom',
        width: 2,
        height: 1,
        isCustom: true,
      ).toJson(),
    ]);
    final service = FrameService(db: db);

    final deletedId = await service.deleteFrame(2);

    expect(deletedId, 2);
    expect(db.deleteCalls, [2]);
  });
}

class _FakeDatabase implements Database {
  _FakeDatabase(List<Map<String, dynamic>> rows)
    : _rows = rows.map(Map<String, Object?>.from).toList();

  final List<Map<String, Object?>> _rows;
  final List<int> updateCalls = [];
  final List<int> deleteCalls = [];

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    bool? distinct,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final id = whereArgs?.firstOrNull;
    if (id == null) {
      return _rows.map(Map<String, Object?>.from).toList();
    }
    return _rows
        .where((row) => row[FramesTable.id] == id)
        .map(Map<String, Object?>.from)
        .toList();
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final id = whereArgs?.first as int?;
    if (id == null) return 0;
    final index = _rows.indexWhere((row) => row[FramesTable.id] == id);
    if (index == -1) return 0;

    updateCalls.add(id);
    _rows[index] = Map<String, Object?>.from(values);
    return 1;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final id = whereArgs?.first as int?;
    if (id == null) return 0;
    final initialLength = _rows.length;
    _rows.removeWhere((row) => row[FramesTable.id] == id);
    if (_rows.length == initialLength) return 0;

    deleteCalls.add(id);
    return 1;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final id = values[FramesTable.id] as int? ?? _rows.length + 1;
    _rows.add({...values, FramesTable.id: id});
    return id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
