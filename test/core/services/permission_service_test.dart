import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/services/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const galChannel = MethodChannel('gal');

  final permissionCalls = <MethodCall>[];
  final galCalls = <MethodCall>[];

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, null);
    permissionCalls.clear();
    galCalls.clear();
  });

  void mockPermissionChannel(Future<Object?> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          permissionCalls.add(call);
          return handler(call);
        });
  }

  void mockGalChannel(Future<Object?> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(galChannel, (call) async {
          galCalls.add(call);
          return handler(call);
        });
  }

  group('camera permissions', () {
    test('isCameraPermissionGranted reads camera status', () async {
      mockPermissionChannel((call) async {
        expect(call.method, 'checkPermissionStatus');
        expect(call.arguments, 1);
        return 1;
      });

      expect(await PermissionService.isCameraPermissionGranted, isTrue);
      expect(permissionCalls.map((call) => call.method), [
        'checkPermissionStatus',
      ]);
    });

    test('requestCameraPermission returns false when denied', () async {
      mockPermissionChannel((call) async {
        expect(call.method, 'requestPermissions');
        expect(call.arguments, [1]);
        return <int, int>{1: 0};
      });

      expect(await PermissionService.requestCameraPermission(), isFalse);
    });

    test(
      'requestCameraPermission opens settings when permanently denied',
      () async {
        mockPermissionChannel((call) async {
          switch (call.method) {
            case 'requestPermissions':
              expect(call.arguments, [1]);
              return <int, int>{1: 4};
            case 'openAppSettings':
              return true;
            default:
              fail('Unexpected permission method: ${call.method}');
          }
        });

        expect(await PermissionService.requestCameraPermission(), isFalse);
        expect(permissionCalls.map((call) => call.method), [
          'requestPermissions',
          'openAppSettings',
        ]);
      },
    );

    test('openSettings delegates to platform settings', () async {
      mockPermissionChannel((call) async {
        expect(call.method, 'openAppSettings');
        return true;
      });

      expect(await PermissionService.openSettings(), isTrue);
    });
  });

  group('storage permissions', () {
    test('isStoragePermissionGranted returns gallery access state', () async {
      mockGalChannel((call) async {
        expect(call.method, 'hasAccess');
        expect(call.arguments, {'toAlbum': false});
        return true;
      });

      expect(await PermissionService.isStoragePermissionGranted, isTrue);
    });

    test(
      'requestStoragePermission returns true when access already exists',
      () async {
        mockGalChannel((call) async {
          expect(call.method, 'hasAccess');
          return true;
        });

        expect(await PermissionService.requestStoragePermission(), isTrue);
        expect(galCalls.map((call) => call.method), ['hasAccess']);
      },
    );

    test('requestStoragePermission requests access when needed', () async {
      mockGalChannel((call) async {
        switch (call.method) {
          case 'hasAccess':
            return false;
          case 'requestAccess':
            expect(call.arguments, {'toAlbum': false});
            return true;
          default:
            fail('Unexpected gallery method: ${call.method}');
        }
      });

      expect(await PermissionService.requestStoragePermission(), isTrue);
      expect(galCalls.map((call) => call.method), [
        'hasAccess',
        'requestAccess',
      ]);
    });

    test('storage permission checks fail closed on gallery errors', () async {
      mockGalChannel((call) async {
        throw PlatformException(code: 'UNEXPECTED');
      });

      expect(await PermissionService.isStoragePermissionGranted, isFalse);
      expect(await PermissionService.requestStoragePermission(), isFalse);
    });
  });
}
