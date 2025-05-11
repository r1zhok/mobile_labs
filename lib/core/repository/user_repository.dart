abstract class UserRepository {
  Future<bool> authenticate(String email, String password);
}