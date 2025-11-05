import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;

  SettingsViewModel(this._authRepository);

  bool get isLoading => _isLoading;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
