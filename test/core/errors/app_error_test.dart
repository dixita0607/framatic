import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';

void main() {
  group('AppError', () {
    test('toString returns developer-facing message', () {
      const error = UnexpectedError('Disk full');

      expect(error.toString(), 'Disk full');
    });

    test('UnexpectedError provides a default user message', () {
      const error = UnexpectedError('Unexpected null');

      expect(error.message, 'Unexpected null');
      expect(error.userMessage, 'Something went wrong. Please try again.');
      expect(error.cause, isNull);
    });

    test('PermissionError preserves user message and cause', () {
      final cause = StateError('denied');
      final error = PermissionError(
        'Permission denied by platform',
        userMessage: 'Permission is required.',
        cause: cause,
      );

      expect(error.message, 'Permission denied by platform');
      expect(error.userMessage, 'Permission is required.');
      expect(error.cause, same(cause));
    });
  });

  group('feature errors', () {
    test('camera errors are AppError instances with stable user messages', () {
      const error = CaptureCameraError(
        'capture failed',
        userMessage: 'Failed to capture photo. Please try again.',
      );

      expect(error, isA<AppError>());
      expect(error, isA<CameraError>());
      expect(error.userMessage, 'Failed to capture photo. Please try again.');
    });

    test('frame reorder error preserves lower-level cause', () {
      final cause = StateError('write failed');
      final error = ReorderFrameError(
        'Error reordering frames: $cause',
        userMessage: 'Failed to reorder frames. Please try again.',
        cause: cause,
      );

      expect(error, isA<FrameError>());
      expect(error.cause, same(cause));
      expect(error.userMessage, 'Failed to reorder frames. Please try again.');
    });

    test('photo save error is surfaced through PhotoError hierarchy', () {
      const error = SavePhotoError(
        'gallery write failed',
        userMessage: 'Failed to save photo to gallery.',
      );

      expect(error, isA<PhotoError>());
      expect(error, isA<AppError>());
      expect(error.toString(), 'gallery write failed');
    });
  });

  group('AppConstants', () {
    test('keeps user-visible app name and frame border values stable', () {
      expect(AppConstants.appName, 'Framatic');
      expect(AppConstants.frameBorder, 16);
    });
  });
}
