import 'package:shared_preferences/shared_preferences.dart';
import 'package:netshots/data/services/auth/auth_service_interface.dart';

class AuthServiceMock implements AuthServiceInterface {
  final SharedPreferences _sharedPreferences;

  AuthServiceMock(this._sharedPreferences);

  @override
  Future<void> login(String email, String password) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Store a mock token and email in shared preferences
    await _sharedPreferences.setString('auth_token', 'mockToken');
    await _sharedPreferences.setString('user_email', email);
  }

  @override
  Future<void> logout() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Clear the mock token and email from shared preferences
    await _sharedPreferences.remove('auth_token');
    await _sharedPreferences.remove('user_email');
  }

  @override
  Future<void> register(String email, String password) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Store a mock token and email in shared preferences
    await _sharedPreferences.setString('auth_token', 'mockToken');
    await _sharedPreferences.setString('user_email', email);
  }

  @override
  Future<bool> isLoggedIn() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    
    // Check if the mock token exists in shared preferences
    return _sharedPreferences.containsKey('auth_token');
  }

  @override
  String? getCurrentUserId() {
    // Simulate getting the current user ID
    // In a real implementation, this would return the user ID from the token
    return _sharedPreferences.getString('auth_token') != null ? 'mockUserId' : null;
  }

  @override
  String? getCurrentUserEmail() {
    // Get the stored email for the current user
    return _sharedPreferences.getString('user_email');
  }
}