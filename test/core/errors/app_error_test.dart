import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';

void main() {
  group('AppError', () {
    test('toString returns developer-facing message', () {
      const message = 'Disk full';
      const error = UnexpectedError(message);

      expect(error.toString(), message);
    });

    test('UnexpectedError provides a default user message', () {
      const message = 'Unexpected null';
      const userMessage = 'Something went wrong. Please try again.';
      const error = UnexpectedError(message);

      expect(error.message, message);
      expect(error.userMessage, userMessage);
      expect(error.cause, isNull);
    });

    test('PermissionError preserves user message and cause', () {
      const message = 'Permission denied by platform';
      const userMessage = 'Permission is required.';
      final cause = StateError('denied');
      final error = PermissionError(
        message,
        userMessage: userMessage,
        cause: cause,
      );

      expect(error.message, message);
      expect(error.userMessage, userMessage);
      expect(error.cause, same(cause));
    });
  });

  group('feature errors', () {
    test('camera errors are AppError instances with stable user messages', () {
      const userMessage = 'Failed to capture photo. Please try again.';
      const error = CaptureCameraError(
        'capture failed',
        userMessage: userMessage,
      );

      expect(error, isA<AppError>());
      expect(error, isA<CameraError>());
      expect(error.userMessage, userMessage);
    });

    test('frame reorder error preserves lower-level cause', () {
      const userMessage = 'Failed to reorder frames. Please try again.';
      final cause = StateError('write failed');
      final error = ReorderFrameError(
        'Error reordering frames: $cause',
        userMessage: userMessage,
        cause: cause,
      );

      expect(error, isA<FrameError>());
      expect(error.cause, same(cause));
      expect(error.userMessage, userMessage);
    });

    test('photo save error is surfaced through PhotoError hierarchy', () {
      const message = 'gallery write failed';
      const error = SavePhotoError(
        message,
        userMessage: 'Failed to save photo to gallery.',
      );

      expect(error, isA<PhotoError>());
      expect(error, isA<AppError>());
      expect(error.toString(), message);
    });
  });
}
