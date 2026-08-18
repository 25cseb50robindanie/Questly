import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyStudents = 'questly_students';
  static const String _keyCurrentStudent = 'questly_current_student';
  static const String _keyProgress = 'questly_progress';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Get all registered users raw Map (key: questlyId, value: Map representing credentials)
  Map<String, dynamic> _getUsersMap() {
    final rawJson = _prefs.getString(_keyStudents);
    if (rawJson == null) return {};
    try {
      return json.decode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // Save users Map
  Future<void> _saveUsersMap(Map<String, dynamic> map) async {
    await _prefs.setString(_keyStudents, json.encode(map));
  }

  // Register user credentials (fails if user already exists)
  Future<bool> registerUserCredentials(String questlyId, String hashedPassword, Map<String, dynamic> studentJson) async {
    final users = _getUsersMap();
    final normalizedId = questlyId.trim().toLowerCase();
    if (users.containsKey(normalizedId)) {
      return false; // User already exists
    }
    users[normalizedId] = {
      'hashedPassword': hashedPassword,
      'student': studentJson,
    };
    await _saveUsersMap(users);
    return true;
  }

  // Save or update user credentials & student profile
  Future<bool> saveUserCredentials(String questlyId, String hashedPassword, Map<String, dynamic> studentJson) async {
    final users = _getUsersMap();
    final normalizedId = questlyId.trim().toLowerCase();
    users[normalizedId] = {
      'hashedPassword': hashedPassword,
      'student': studentJson,
    };
    await _saveUsersMap(users);
    return true;
  }

  // Update existing user student profile in stored users map
  Future<void> updateUserStudentProfile(String questlyId, Map<String, dynamic> studentJson) async {
    final users = _getUsersMap();
    final normalizedId = questlyId.trim().toLowerCase();
    if (users.containsKey(normalizedId)) {
      final existingCreds = users[normalizedId] as Map<String, dynamic>;
      existingCreds['student'] = studentJson;
      users[normalizedId] = existingCreds;
      await _saveUsersMap(users);
    }
  }

  // Retrieve user password hash and student JSON
  Map<String, dynamic>? getUserCredentials(String questlyId) {
    final users = _getUsersMap();
    final normalizedId = questlyId.trim().toLowerCase();
    if (!users.containsKey(normalizedId)) return null;
    return users[normalizedId] as Map<String, dynamic>?;
  }

  // Set currently logged-in student
  Future<void> setCurrentStudent(Map<String, dynamic>? studentJson) async {
    if (studentJson == null) {
      await _prefs.remove(_keyCurrentStudent);
    } else {
      await _prefs.setString(_keyCurrentStudent, json.encode(studentJson));
    }
  }

  // Get currently logged-in student
  Map<String, dynamic>? getCurrentStudent() {
    final raw = _prefs.getString(_keyCurrentStudent);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Save progress for an activity
  Future<void> saveProgress(String studentId, String activityId, Map<String, dynamic> progressJson) async {
    final normalizedId = studentId.toLowerCase();
    final progressList = _getProgressListRaw();
    final key = '${normalizedId}_$activityId';
    progressList[key] = progressJson;
    await _prefs.setString(_keyProgress, json.encode(progressList));
  }

  // Get progress maps
  Map<String, dynamic> _getProgressListRaw() {
    final raw = _prefs.getString(_keyProgress);
    if (raw == null) return {};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // Retrieve progress list for a student
  List<Map<String, dynamic>> getProgressForStudent(String studentId) {
    final normalizedId = studentId.toLowerCase();
    final allProgress = _getProgressListRaw();
    final list = <Map<String, dynamic>>[];
    allProgress.forEach((key, value) {
      if (key.startsWith('${normalizedId}_')) {
        list.add(value as Map<String, dynamic>);
      }
    });
    return list;
  }

  // Language settings
  Future<void> saveLanguage(String lang) async {
    await _prefs.setString('questly_language', lang);
  }

  String getLanguage() {
    return _prefs.getString('questly_language') ?? 'en';
  }

  // Badges lists
  List<String> getUnlockedBadgesRaw(String studentId) {
    final list = _prefs.getStringList('questly_badges_${studentId.toLowerCase()}');
    return list ?? [];
  }

  Future<void> saveUnlockedBadgesRaw(String studentId, List<String> list) async {
    await _prefs.setStringList('questly_badges_${studentId.toLowerCase()}', list);
  }

  // Collectibles lists
  List<String> getUnlockedCollectiblesRaw(String studentId) {
    final list = _prefs.getStringList('questly_collectibles_${studentId.toLowerCase()}');
    return list ?? [];
  }

  Future<void> saveUnlockedCollectiblesRaw(String studentId, List<String> list) async {
    await _prefs.setStringList('questly_collectibles_${studentId.toLowerCase()}', list);
  }

  // Purchased Rewards lists (Cosmetics)
  List<String> getPurchasedRewardsRaw(String studentId) {
    final list = _prefs.getStringList('questly_rewards_${studentId.toLowerCase()}');
    return list ?? [];
  }

  Future<void> savePurchasedRewardsRaw(String studentId, List<String> list) async {
    await _prefs.setStringList('questly_rewards_${studentId.toLowerCase()}', list);
  }

  // Notifications
  List<dynamic> getNotificationsRaw(String studentId) {
    final raw = _prefs.getString('questly_notifications_${studentId.toLowerCase()}');
    if (raw == null) return [];
    try {
      return json.decode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotificationsRaw(String studentId, List<dynamic> list) async {
    await _prefs.setString('questly_notifications_${studentId.toLowerCase()}', json.encode(list));
  }

  // Generic key-value helpers for V0.3 progression states
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
}

