import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class LogoutViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoggingOut = false;

  LogoutViewModel(this._authRepository);

  bool get isLoggingOut => _isLoggingOut;

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    notifyListeners();
    try {
      await _authRepository.logout();
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}