import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static const String _tokenKey = 'projectApiKey';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userRoleKey = 'userRole';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // --- Token Methods ---
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool get hasToken => _prefs.containsKey(_tokenKey);

  // --- User Methods ---
  Future<void> saveUserData({
    required String id,
    required String email,
    required String name,
    required String role,
  }) async {
    await _prefs.setString(_userIdKey, id);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userRoleKey, role);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
