import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/services/preferences_service.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('getStringList returns an empty list for a missing key', () async {
    final value = await PreferencesService.getStringList(
      'missing_frames_order',
    );

    expect(value, isEmpty);
  });

  test('getStringList returns values for an existing key', () async {
    const key = 'existing_frames_order';
    const order = ['3', '1', '2'];
    await PreferencesService.setStringList(key, order);

    expect(await PreferencesService.getStringList(key), order);
  });

  test('setStringList persists and reads frame ordering values', () async {
    const key = 'frames_order_test_key';
    const order = ['2', '1', '3'];

    await PreferencesService.setStringList(key, order);

    expect(await PreferencesService.getStringList(key), order);
  });
}
