import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoginSuccessful = false;
  bool _isLoading = false;

  LoginViewModel(this._authRepository);

  bool get isLoginSuccessful => _isLoginSuccessful;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authRepository.login(email, password);
      _isLoading = false;
      _isLoginSuccessful = true;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}