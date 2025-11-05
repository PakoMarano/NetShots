import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class LogoutViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LogoutViewModel(this._authRepository);

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}