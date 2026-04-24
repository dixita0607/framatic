import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/utils/frame_calculator.dart';

void main() {
  group('fitToAspectRatio', () {
    test('landscape ratio fits within bounds', () {
      final result = fitToAspectRatio(
        maxWidth: 400,
        maxHeight: 400,
        aspectRatio: 16 / 9,
      );

      expect(result.width, 400);
      expect(result.height, closeTo(225, 0.1));
    });

    test('portrait ratio fits within bounds', () {
      final result = fitToAspectRatio(
        maxWidth: 400,
        maxHeight: 400,
        aspectRatio: 9 / 16,
      );

      expect(result.width, closeTo(225, 0.1));
      expect(result.height, 400);
    });

    test('square ratio fits within bounds', () {
      final result = fitToAspectRatio(
        maxWidth: 400,
        maxHeight: 400,
        aspectRatio: 1,
      );

      expect(result.width, 400);
      expect(result.height, 400);
    });

    test('width-constrained: wide ratio in narrow bounds', () {
      final result = fitToAspectRatio(
        maxWidth: 200,
        maxHeight: 400,
        aspectRatio: 16 / 9,
      );

      // Width is the constraint — should use full width
      expect(result.width, 200);
      expect(result.height, closeTo(112.5, 0.1));
    });

    test('height-constrained: tall ratio in short bounds', () {
      final result = fitToAspectRatio(
        maxWidth: 400,
        maxHeight: 200,
        aspectRatio: 9 / 16,
      );

      // Height is the constraint — should use full height
      expect(result.height, 200);
      expect(result.width, closeTo(112.5, 0.1));
    });

    test('result never exceeds bounds', () {
      final ratios = [16 / 9, 9 / 16, 1.0, 4 / 3, 3 / 4, 21 / 9];

      for (final ratio in ratios) {
        final result = fitToAspectRatio(
          maxWidth: 300,
          maxHeight: 500,
          aspectRatio: ratio,
        );

        expect(result.width, lessThanOrEqualTo(300));
        expect(result.height, lessThanOrEqualTo(500));
      }
    });
  });
}
