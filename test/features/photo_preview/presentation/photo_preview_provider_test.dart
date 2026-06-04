import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const galChannel = MethodChannel('gal');

  late _FakePhotoRepository repository;
  late PhotoPreviewProvider provider;
  final galCalls = <MethodCall>[];

  setUp(() {
    repository = _FakePhotoRepository();
    provider = PhotoPreviewProvider(repository);
    galCalls.clear();
  });

  tearDown(() {
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, null);
  });

  void mockGalleryPermission({
    required bool hasAccess,
    bool requestAccess = true,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, (call) async {
          galCalls.add(call);
          switch (call.method) {
            case 'hasAccess':
              return hasAccess;
            case 'requestAccess':
              return requestAccess;
            default:
              fail('Unexpected gal method: ${call.method}');
          }
        });
  }

  test('processPhotoWithFrame delegates image path and frame', () async {
    final frame = Frame(id: 1, title: 'Square', width: 1, height: 1);
    repository.processedPath = '/tmp/processed.jpg';

    final result = await provider.processPhotoWithFrame(
      imagePath: '/tmp/source.jpg',
      frame: frame,
    );

    expect(result, '/tmp/processed.jpg');
    expect(repository.processCalls.single.imagePath, '/tmp/source.jpg');
    expect(repository.processCalls.single.frame, same(frame));
  });

  test('savePhoto saves after gallery permission is already granted', () async {
    mockGalleryPermission(hasAccess: true);
    final isSavingValues = <bool>[];
    provider.addListener(() => isSavingValues.add(provider.isSaving));

    await provider.savePhoto('/tmp/processed.jpg');

    expect(repository.savedPaths, ['/tmp/processed.jpg']);
    expect(provider.isSaving, isFalse);
    expect(isSavingValues, [true, false]);
    expect(galCalls.map((call) => call.method), ['hasAccess']);
  });

  test(
    'savePhoto requests access and surfaces denied storage permission',
    () async {
      mockGalleryPermission(hasAccess: false, requestAccess: false);
      final isSavingValues = <bool>[];
      provider.addListener(() => isSavingValues.add(provider.isSaving));

      await expectLater(
        provider.savePhoto('/tmp/processed.jpg'),
        throwsA(isA<PermissionError>()),
      );

      expect(repository.savedPaths, isEmpty);
      expect(provider.isSaving, isFalse);
      expect(isSavingValues, [true, false]);
      expect(galCalls.map((call) => call.method), [
        'hasAccess',
        'requestAccess',
      ]);
    },
  );

  test('savePhoto resets saving state when repository fails', () async {
    mockGalleryPermission(hasAccess: true);
    const error = SavePhotoError(
      'write failed',
      userMessage: 'Failed to save photo to gallery.',
    );
    repository.saveError = error;

    await expectLater(
      provider.savePhoto('/tmp/processed.jpg'),
      throwsA(same(error)),
    );

    expect(provider.isSaving, isFalse);
  });

  test('retakePhoto deletes the temporary image file', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'framatic_photo_preview_provider_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true).ignore());
    final file = File('${tempDir.path}/retake.jpg');
    await file.writeAsString('temporary image bytes');

    provider.retakePhoto(file.path);
    await pumpEventQueue(times: 5);

    expect(await file.exists(), isFalse);
  });

  test('successMessage names the app album', () {
    expect(provider.successMessage, 'Photo saved to Framatic album');
  });
}

class _ProcessCall {
  const _ProcessCall({required this.imagePath, required this.frame});

  final String imagePath;
  final Frame frame;
}

class _FakePhotoRepository implements PhotoRepository {
  final processCalls = <_ProcessCall>[];
  final savedPaths = <String>[];

  String processedPath = '/tmp/default-processed.jpg';
  Object? saveError;

  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    processCalls.add(_ProcessCall(imagePath: imagePath, frame: frame));
    return processedPath;
  }

  @override
  Future<void> saveToGallery(String imagePath) async {
    if (saveError != null) throw saveError!;
    savedPaths.add(imagePath);
  }
}
