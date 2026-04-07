import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/utils/constants.dart';
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

  group('calculateFrameSize', () {
    test('returns size smaller than input bounds (padding applied)', () {
      final size = calculateFrameSize(
        maxWidth: 400,
        maxHeight: 800,
        aspectRatio: 16 / 9,
      );

      expect(size.width, lessThan(400));
      expect(size.height, lessThan(800));
    });

    test('maintains aspect ratio', () {
      final size = calculateFrameSize(
        maxWidth: 400,
        maxHeight: 800,
        aspectRatio: 16 / 9,
      );

      expect(size.width / size.height, closeTo(16 / 9, 0.01));
    });

    test('different aspect ratios produce different dimensions', () {
      final wide = calculateFrameSize(
        maxWidth: 400,
        maxHeight: 400,
        aspectRatio: 16 / 9,
      );
      final tall = calculateFrameSize(
        maxWidth: 400,
        maxHeight: 400,
        aspectRatio: 9 / 16,
      );

      // Wide frame should be wider and shorter than tall frame
      expect(wide.width, greaterThan(tall.width));
      expect(wide.height, lessThan(tall.height));
    });

    test('accounts for border factor in sizing', () {
      // Frame size should be smaller than just padding alone
      // because border space is also reserved
      final borderFactor = 1 + (2 * AppConstants.frameBorderPercentage);
      final paddedWidth = 400 * AppConstants.maxFramePadding;

      final size = calculateFrameSize(
        maxWidth: 400,
        maxHeight: 800,
        aspectRatio: 1,
      );

      expect(size.width, lessThan(paddedWidth));
      expect(size.width, closeTo(paddedWidth / borderFactor, 0.1));
    });
  });
}
