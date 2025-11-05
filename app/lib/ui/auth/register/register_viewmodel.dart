import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isRegistrationSuccessful = false;
  bool _isLoading = false;

  RegisterViewModel(this._authRepository);

  bool get isRegistrationSuccessful => _isRegistrationSuccessful;
  bool get isLoading => _isLoading;

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authRepository.register(email, password);
      _isLoading = false;
      _isRegistrationSuccessful = true;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}