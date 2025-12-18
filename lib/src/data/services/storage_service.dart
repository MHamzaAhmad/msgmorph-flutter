import 'package:shared_preferences/shared_preferences.dart';
import 'package:msgmorph/src/core/constants.dart';

/// Local storage service for persisting visitor ID and session data
class StorageService {
  StorageService._();

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  /// Get singleton instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize storage
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get or create visitor ID
  Future<String> getOrCreateVisitorId() async {
    await init();

    String? visitorId = _prefs!.getString(StorageKeys.visitorId);
    if (visitorId == null) {
      visitorId = _generateVisitorId();
      await _prefs!.setString(StorageKeys.visitorId, visitorId);
    }
    return visitorId;
  }

  /// Get stored visitor ID (may be null)
  Future<String?> getVisitorId() async {
    await init();
    return _prefs!.getString(StorageKeys.visitorId);
  }

  /// Set visitor ID
  Future<void> setVisitorId(String visitorId) async {
    await init();
    await _prefs!.setString(StorageKeys.visitorId, visitorId);
  }

  /// Get active session ID
  Future<String?> getActiveSessionId() async {
    await init();
    return _prefs!.getString(StorageKeys.activeSessionId);
  }

  /// Set active session ID
  Future<void> setActiveSessionId(String? sessionId) async {
    await init();
    if (sessionId == null) {
      await _prefs!.remove(StorageKeys.activeSessionId);
    } else {
      await _prefs!.setString(StorageKeys.activeSessionId, sessionId);
    }
  }

  /// Clear all stored data
  Future<void> clear() async {
    await init();
    await _prefs!.remove(StorageKeys.visitorId);
    await _prefs!.remove(StorageKeys.activeSessionId);
  }

  /// Generate a unique visitor ID
  String _generateVisitorId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = _randomString(8);
    return 'visitor_$random$timestamp';
  }

  /// Generate random string
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[(random + i * 7) % chars.length]);
    }
    return buffer.toString();
  }
}
