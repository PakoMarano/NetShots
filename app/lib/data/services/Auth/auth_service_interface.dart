abstract class AuthServiceInterface {
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> register(String email, String password);
  Future<bool> isLoggedIn();
  String? getCurrentUserId();
  String? getCurrentUserEmail();
}