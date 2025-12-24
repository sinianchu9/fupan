import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserSession {
  static const String _userIdKey = 'x_user_id';
  String? _userId;

  String get userId {
    if (_userId == null) {
      throw Exception('UserSession not initialized. Call init() first.');
    }
    return _userId!;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey);

    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString(_userIdKey, _userId!);
    }
  }
}
