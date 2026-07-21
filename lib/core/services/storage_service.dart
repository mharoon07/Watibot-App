import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static const String _tokenKey = 'projectApiKey';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userRoleKey = 'userRole';
  static const String _userAvatarKey = 'userAvatar';

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
    String? avatar,
  }) async {
    await _prefs.setString(_userIdKey, id);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userRoleKey, role);
    if (avatar != null && avatar.isNotEmpty) {
      await _prefs.setString(_userAvatarKey, avatar);
    } else {
      await _prefs.remove(_userAvatarKey);
    }
  }

  String? get userId => _prefs.getString(_userIdKey);
  String? get userEmail => _prefs.getString(_userEmailKey);
  String? get userName => _prefs.getString(_userNameKey);
  String? get userRole => _prefs.getString(_userRoleKey);
  String? get userAvatar => _prefs.getString(_userAvatarKey);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
