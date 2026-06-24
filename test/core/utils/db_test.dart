import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/db.dart';
import 'package:framatic/features/frames_manager/data/frame_service.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DBSchemaValues.dbVersion,
        onCreate: DBSchema.create,
      ),
    );
  });

  tearDown(() => db.close());

  test('rejects frame names that only differ by case or whitespace', () async {
    await expectLater(
      db.insert(
        FramesTable.name,
        Frame(title: ' 16:9 ', width: 32, height: 9, isCustom: true).toJson(),
      ),
      throwsA(
        isA<DatabaseException>().having(
          (error) => error.isUniqueConstraintError(),
          'is unique constraint error',
          isTrue,
        ),
      ),
    );
  });

  test('rejects an exact duplicate width and height pair', () async {
    await expectLater(
      db.insert(
        FramesTable.name,
        Frame(
          title: 'Classic copy',
          width: 4,
          height: 3,
          isCustom: true,
        ).toJson(),
      ),
      throwsA(
        isA<DatabaseException>().having(
          (error) => error.isUniqueConstraintError(),
          'is unique constraint error',
          isTrue,
        ),
      ),
    );
  });

  test(
    'allows proportionally equivalent dimensions like the form does',
    () async {
      final id = await db.insert(
        FramesTable.name,
        Frame(
          title: 'Large Classic',
          width: 8,
          height: 6,
          isCustom: true,
        ).toJson(),
      );

      expect(id, greaterThan(0));
    },
  );

  test('service converts uniqueness failures into frame errors', () async {
    final service = FrameService(db: db);

    await expectLater(
      service.createFrame(
        Frame(title: '16:9', width: 32, height: 9, isCustom: true),
      ),
      throwsA(
        isA<CreateFrameError>().having(
          (error) => error.userMessage,
          'user message',
          'A frame with that name or ratio already exists.',
        ),
      ),
    );

    final customFrame = await service.createFrame(
      Frame(title: 'Custom', width: 2, height: 1, isCustom: true),
    );

    await expectLater(
      service.updateFrame(
        customFrame.copyWith(title: 'Square', width: 1, height: 1),
      ),
      throwsA(
        isA<UpdateFrameError>().having(
          (error) => error.userMessage,
          'user message',
          'A frame with that name or ratio already exists.',
        ),
      ),
    );
  });
}
