import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoginSuccessful = false;
  bool _isLoading = false;
  String? _errorMessage;

  LoginViewModel(this._authRepository);

  bool get isLoginSuccessful => _isLoginSuccessful;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await _authRepository.login(email, password);
      _isLoading = false;
      _isLoginSuccessful = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}