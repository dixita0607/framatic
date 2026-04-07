import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';

void main() {
  group('serialization', () {
    test('toJson maps isCustom bool to int', () {
      final json = Frame(
        id: 1,
        title: 'Test',
        width: 16,
        height: 9,
        isCustom: true,
      ).toJson();

      expect(json[FramesTable.isCustom], 1);

      final json2 = Frame(
        title: 'Test',
        width: 16,
        height: 9,
      ).toJson();

      expect(json2[FramesTable.isCustom], 0);
    });

    test('fromJson roundtrip preserves all fields', () {
      final original = Frame(
        id: 1,
        title: 'Widescreen',
        width: 16,
        height: 9,
        isCustom: true,
      );
      final restored = Frame.fromJson(original.toJson());

      expect(restored, equals(original));
    });

    test('fromJson roundtrip with null id', () {
      final original = Frame(
        title: 'Square',
        width: 1,
        height: 1,
      );
      final restored = Frame.fromJson(original.toJson());

      expect(restored.id, isNull);
      expect(restored.title, original.title);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
      expect(restored.isCustom, original.isCustom);
    });
  });
}
