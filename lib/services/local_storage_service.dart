import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService._();

  static void setLocalStorageData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value.toString());
  }

  static Future<dynamic> getLocalStorageData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) ?? '';
  }

  static Future<void> removeLocalStorageData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
