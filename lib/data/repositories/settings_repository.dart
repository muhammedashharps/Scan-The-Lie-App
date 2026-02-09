import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';

/// Repository for managing app settings in Hive
class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _apiKeyKey = 'gemini_api_key';

  Box? _box;

  /// Initialize the repository
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  /// Get the stored Gemini API key
  String? getApiKey() {
    return _box?.get(_apiKeyKey);
  }

  /// Save the Gemini API key
  Future<void> saveApiKey(String apiKey) async {
    await _box?.put(_apiKeyKey, apiKey);
    await _box?.flush();
  }

  /// Check if API key is set
  bool get hasApiKey => getApiKey()?.isNotEmpty ?? false;

  /// Clear the API key
  Future<void> clearApiKey() async {
    await _box?.delete(_apiKeyKey);
  }

  /// Get a generic setting
  T? getSetting<T>(String key) {
    return _box?.get(key) as T?;
  }

  /// Save a generic setting
  Future<void> saveSetting<T>(String key, T value) async {
    await _box?.put(key, value);
  }

  static const String _prefsKey = 'user_preferences';

  UserPreferences getUserPreferences() {
    return _box?.get(_prefsKey) as UserPreferences? ?? UserPreferences();
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    await _box?.put(_prefsKey, prefs);
    await _box?.flush();
  }

  static const String _savedReportIdsKey = 'saved_report_ids';

  int getSavedReportCount() {
    final ids = _box?.get(_savedReportIdsKey, defaultValue: <String>[]) as List;
    return ids.length;
  }

  Future<void> incrementSavedReportCount(String productId) async {
    final ids = List<String>.from(
      _box?.get(_savedReportIdsKey, defaultValue: <String>[]) as List,
    );

    if (!ids.contains(productId)) {
      ids.add(productId);
      await _box?.put(_savedReportIdsKey, ids);
      await _box?.flush(); // Ensure persistence
    }
  }

  // Expose listenable
  ValueListenable<Box>? getListenable() {
    return _box?.listenable();
  }

  /// Watch for changes to UserPreferences
  Stream<UserPreferences> watchUserPreferences() async* {
    if (_box == null) await init();

    // Emit current value first
    yield getUserPreferences();

    // Watch for specific key changes
    yield* _box!
        .watch(key: _prefsKey)
        .where((event) => event.value != null)
        .map((event) => event.value as UserPreferences);
  }
}
