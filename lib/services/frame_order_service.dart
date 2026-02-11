import 'package:shared_preferences/shared_preferences.dart';

const orderKey = 'frames_order';

class FrameOrderService {
  static late final SharedPreferencesWithCache _preferences;

  static Future<void> initialize() async {
    _preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{orderKey},
      ),
    );
  }

  static List<String> get order => _preferences.getStringList(orderKey) ?? [];

  static Future<void> setOrder(List<String> order) async =>
      await _preferences.setStringList(orderKey, order);
}
