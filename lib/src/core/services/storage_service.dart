import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<SharedPreferences> _getPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      throw Exception('Storage unavailable');
    }
  }

  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  Future<String?> getString(String key) async {
    try {
      final prefs = await _getPreferences();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _getPreferences();
      return prefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setInt(key, value);
    } catch (_) {}
  }

  Future<int?> getInt(String key) async {
    try {
      final prefs = await _getPreferences();
      return prefs.getInt(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStringList(String key, List<String> value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setStringList(key, value);
    } catch (_) {}
  }

  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _getPreferences();
      return prefs.getStringList(key);
    } catch (_) {
      return null;
    }
  }
}
