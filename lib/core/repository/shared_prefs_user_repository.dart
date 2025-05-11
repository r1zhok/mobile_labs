import 'package:shared_preferences/shared_preferences.dart';
import 'user_repository.dart';

class SharedPrefsUserRepository implements UserRepository {
  @override
  Future<bool> authenticate(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');

    return email == savedEmail && password == savedPassword;
  }
}