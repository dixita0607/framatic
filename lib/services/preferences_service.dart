import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferencesWithCache? _preferences;

  static Future<SharedPreferencesWithCache> _getPreferences() async {
    return _preferences ??= await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  static Future<List<String>> getStringList(String key) async =>
      (await _getPreferences()).getStringList(key) ?? [];

  static Future<void> setStringList(String key, List<String> value) async =>
      (await _getPreferences()).setStringList(key, value);
}
