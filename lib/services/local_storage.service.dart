import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;
  static bool _isInitializing = false;

  static Future<SharedPreferences?> getPrefs() async {
    if (_prefs != null) return _prefs;
    
    if (_isInitializing) {
      int retries = 0;
      while (_isInitializing && retries < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
      if (_prefs != null) return _prefs;
    }

    _isInitializing = true;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (error) {
      print("LocalStorageService: First attempt error => $error. Retrying in 200ms...");
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (retryError) {
        print("LocalStorageService: Retry error => $retryError");
      }
    } finally {
      _isInitializing = false;
    }
    return _prefs;
  }

  static SharedPreferences? get prefs => _prefs;
}
