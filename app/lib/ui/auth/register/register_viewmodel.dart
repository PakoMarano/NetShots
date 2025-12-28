import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isRegistrationSuccessful = false;
  bool _isLoading = false;
  String? _errorMessage;

  RegisterViewModel(this._authRepository);

  bool get isRegistrationSuccessful => _isRegistrationSuccessful;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await _authRepository.register(email, password);
      _isLoading = false;
      _isRegistrationSuccessful = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}