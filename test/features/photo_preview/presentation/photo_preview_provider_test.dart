import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class FakePhotoRepository implements PhotoRepository {
  String? processedPath;
  Exception? errorOnProcess;
  Exception? errorOnSave;

  bool saveToGalleryCalled = false;
  String? lastSavedPath;

  FakePhotoRepository({this.processedPath, this.errorOnProcess, this.errorOnSave});

  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    if (errorOnProcess != null) throw errorOnProcess!;
    return processedPath ?? '/processed/$imagePath';
  }

  @override
  Future<void> saveToGallery(String imagePath) async {
    if (errorOnSave != null) throw errorOnSave!;
    saveToGalleryCalled = true;
    lastSavedPath = imagePath;
  }
}

// ---------------------------------------------------------------------------
// Mock platform channels for permission (Gal) and storage
// ---------------------------------------------------------------------------

/// Mock Gal's platform channel to grant access.
void _mockGalGranted() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('gal'),
    (call) async {
      if (call.method == 'hasAccess') return true;
      if (call.method == 'requestAccess') return true;
      if (call.method == 'putImage') return null;
      if (call.method == 'putVideo') return null;
      if (call.method == 'putImageBytes') return null;
      return null;
    },
  );
}

/// Mock Gal's platform channel to deny access.
void _mockGalDenied() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('gal'),
    (call) async {
      if (call.method == 'hasAccess') return false;
      if (call.method == 'requestAccess') return false;
      return null;
    },
  );
}

void _clearGalMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('gal'), null);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhotoPreviewProvider', () {
    group('processPhotoWithFrame', () {
      test('delegates to repository and returns result', () async {
        final repo = FakePhotoRepository(processedPath: '/output/photo.jpg');
        final provider = PhotoPreviewProvider(repo);

        final frame = Frame(id: 1, title: '16:9', width: 16, height: 9);
        final result = await provider.processPhotoWithFrame(
          imagePath: '/input/photo.jpg',
          frame: frame,
        );

        expect(result, '/output/photo.jpg');
      });

      test('propagates repository error', () async {
        final repo = FakePhotoRepository(
          errorOnProcess: Exception('processing failed'),
        );
        final provider = PhotoPreviewProvider(repo);

        final frame = Frame(id: 1, title: '16:9', width: 16, height: 9);

        expect(
          () => provider.processPhotoWithFrame(
            imagePath: '/input/photo.jpg',
            frame: frame,
          ),
          throwsException,
        );
      });
    });

    group('savePhoto', () {
      setUp(_mockGalGranted);
      tearDown(_clearGalMock);

      test('sets isSaving to true during call and resets to false after', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        bool savingDuring = false;
        provider.addListener(() {
          if (provider.isSaving) savingDuring = true;
        });

        await provider.savePhoto('/photo.jpg');

        expect(savingDuring, isTrue);
        expect(provider.isSaving, isFalse);
      });

      test('calls saveToGallery on the repository', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        await provider.savePhoto('/photo.jpg');

        expect(repo.saveToGalleryCalled, isTrue);
        expect(repo.lastSavedPath, '/photo.jpg');
      });

      test('isSaving is false after savePhoto completes', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        await provider.savePhoto('/photo.jpg');

        expect(provider.isSaving, isFalse);
      });

      test('rethrows AppError and resets isSaving to false', () async {
        final repo = FakePhotoRepository(
          errorOnSave: const DatabaseError(
            'save failed',
            userMessage: 'Failed to save.',
          ),
        );
        final provider = PhotoPreviewProvider(repo);

        await expectLater(
          () => provider.savePhoto('/photo.jpg'),
          throwsA(isA<AppError>()),
        );
        expect(provider.isSaving, isFalse);
      });
    });

    group('savePhoto - permission denied', () {
      setUp(_mockGalDenied);
      tearDown(_clearGalMock);

      test('throws PermissionError when storage permission is denied', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        await expectLater(
          () => provider.savePhoto('/photo.jpg'),
          throwsA(isA<PermissionError>()),
        );
      });

      test('resets isSaving to false when permission denied', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        try {
          await provider.savePhoto('/photo.jpg');
        } catch (_) {}

        expect(provider.isSaving, isFalse);
      });

      test('does not call saveToGallery when permission denied', () async {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        try {
          await provider.savePhoto('/photo.jpg');
        } catch (_) {}

        expect(repo.saveToGalleryCalled, isFalse);
      });
    });

    group('retakePhoto', () {
      test('attempts to delete the file at the given path', () async {
        // Create a real temp file so File.delete() has something to work on.
        final tmpFile = File('${Directory.systemTemp.path}/retake_test.jpg');
        tmpFile.writeAsStringSync('test');

        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        // retakePhoto is fire-and-forget (delete().ignore()), so just verify
        // it does not throw.
        expect(() => provider.retakePhoto(tmpFile.path), returnsNormally);

        // Give the async delete a chance to complete before the test ends.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      test('does not throw when file does not exist', () {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        expect(
          () => provider.retakePhoto('/nonexistent/path/photo.jpg'),
          returnsNormally,
        );
      });
    });

    group('successMessage', () {
      test('returns expected string mentioning app name', () {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        expect(provider.successMessage, contains('Framatic'));
      });

      test('returns correct full message', () {
        final repo = FakePhotoRepository();
        final provider = PhotoPreviewProvider(repo);

        expect(provider.successMessage, 'Photo saved to Framatic album');
      });
    });
  });
}
