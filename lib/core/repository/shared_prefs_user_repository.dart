import 'package:shared_preferences/shared_preferences.dart';
import 'user_repository.dart';

class SharedPrefsUserRepository implements UserRepository {
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';

  @override
  Future<bool> authenticate(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_keyEmail);
    final savedPassword = prefs.getString(_keyPassword);

    return email == savedEmail && password == savedPassword;
  }

  @override
  Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  @override
  Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
  }
}