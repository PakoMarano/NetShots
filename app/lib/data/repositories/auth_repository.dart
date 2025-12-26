import 'package:netshots/data/services/auth/auth_service_interface.dart';

class AuthRepository {
  final AuthServiceInterface _authService;

  AuthRepository(this._authService);

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> register(String email, String password) async {
    await _authService.register(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  String? getCurrentUserId() {
    return _authService.getCurrentUserId();
  }

  String? getCurrentUserEmail() {
    return _authService.getCurrentUserEmail();
  }
}