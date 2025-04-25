abstract class UserRepository {
  Future<void> saveUser(String email, String password);
  Future<bool> authenticate(String email, String password);
  Future<Map<String, String>?> getUser();
  Future<void> clearUser();
}