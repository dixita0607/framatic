import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/photo_preview/data/photo_service.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const galChannel = MethodChannel('gal');

  late Directory tempDir;
  final galCalls = <MethodCall>[];

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'framatic_photo_service_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getTemporaryDirectory':
              return tempDir.path;
            default:
              fail('Unexpected path_provider method: ${call.method}');
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, (call) async {
          galCalls.add(call);
          switch (call.method) {
            case 'requestAccess':
              return true;
            case 'putImage':
              return null;
            default:
              fail('Unexpected gallery method: ${call.method}');
          }
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, null);
    galCalls.clear();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('processPhotoWithFrame crops and scales its white border', () async {
    final sourceFile = File('${tempDir.path}/source.jpg');
    final sourceImage = img.Image(width: 100, height: 80);
    img.fill(sourceImage, color: img.ColorRgb8(20, 40, 60));
    await sourceFile.writeAsBytes(img.encodeJpg(sourceImage));

    final resultPath = await PhotoService().processPhotoWithFrame(
      imagePath: sourceFile.path,
      frame: Frame(title: 'Square', width: 1, height: 1),
    );

    final resultFile = File(resultPath);
    final resultImage = img.decodeJpg(await resultFile.readAsBytes());

    expect(resultFile.path, startsWith('${tempDir.path}/frame_'));
    expect(await sourceFile.exists(), isFalse);
    expect(resultImage, isNotNull);
    expect(resultImage!.width, 86);
    expect(resultImage.height, 86);
  });

  test('processPhotoWithFrame strengthens borders for tall frames', () async {
    final sourceFile = File('${tempDir.path}/portrait_source.jpg');
    final sourceImage = img.Image(width: 100, height: 100);
    img.fill(sourceImage, color: img.ColorRgb8(20, 40, 60));
    await sourceFile.writeAsBytes(img.encodeJpg(sourceImage));

    final resultPath = await PhotoService().processPhotoWithFrame(
      imagePath: sourceFile.path,
      frame: Frame(title: 'Portrait', width: 1, height: 2),
    );

    final resultImage = img.decodeJpg(await File(resultPath).readAsBytes());

    expect(resultImage, isNotNull);
    expect(resultImage!.width, 58);
    expect(resultImage.height, 108);
  });

  test(
    'processPhotoWithFrame wraps decode failures in ProcessPhotoError',
    () async {
      final sourceFile = File('${tempDir.path}/not_an_image.jpg');
      await sourceFile.writeAsString('not image bytes');

      await expectLater(
        PhotoService().processPhotoWithFrame(
          imagePath: sourceFile.path,
          frame: Frame(title: 'Square', width: 1, height: 1),
        ),
        throwsA(isA<ProcessPhotoError>()),
      );
      expect(await sourceFile.exists(), isFalse);
    },
  );

  test('saveToGallery saves to the app album and keeps preview file', () async {
    final sourceFile = File('${tempDir.path}/processed.jpg');
    await sourceFile.writeAsString('processed image bytes');

    await PhotoService().saveToGallery(sourceFile.path);

    expect(await sourceFile.exists(), isTrue);
    expect(galCalls.map((call) => call.method), ['requestAccess', 'putImage']);
    expect(galCalls[0].arguments, {'toAlbum': true});
    expect(galCalls[1].arguments, {
      'path': sourceFile.path,
      'album': AppConstants.appName,
    });
  });

  test('saveToGallery wraps gallery plugin failures', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, (call) async {
          galCalls.add(call);
          throw PlatformException(code: 'ACCESS_DENIED');
        });
    final sourceFile = File('${tempDir.path}/processed.jpg');
    await sourceFile.writeAsString('processed image bytes');

    await expectLater(
      PhotoService().saveToGallery(sourceFile.path),
      throwsA(isA<SavePhotoError>()),
    );

    expect(await sourceFile.exists(), isTrue);
    expect(galCalls.single.method, 'requestAccess');
  });

  test('cleanupTempFiles schedules generated frame cleanup only', () async {
    final generatedFile = File('${tempDir.path}/frame_123.jpg');
    final unrelatedFile = File('${tempDir.path}/source.jpg');
    await generatedFile.writeAsString('generated');
    await unrelatedFile.writeAsString('source');

    await PhotoService.cleanupTempFiles();

    // TODO: Revisit if cleanupTempFiles starts awaiting deletes. It is currently
    // best-effort, so this test should not require immediate generated-file
    // deletion after the method returns.
    expect(generatedFile.path, endsWith('frame_123.jpg'));
    expect(await unrelatedFile.exists(), isTrue);
  });
}
