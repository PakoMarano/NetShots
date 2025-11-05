import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/auth_repository.dart';
import 'package:netshots/data/models/user_profile_model.dart';

class CreateProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  bool _isProfileCreated = false;
  bool _isLoading = false;
  VoidCallback? _onProfileCreated;

  CreateProfileViewModel(this._profileRepository, this._authRepository);

  bool get isProfileCreated => _isProfileCreated;
  bool get isLoading => _isLoading;
  
  void setOnProfileCreatedCallback(VoidCallback callback) {
    _onProfileCreated = callback;
  }

  Future<void> createProfile(
    String firstName,
    String lastName,
    DateTime birthDate,
    Gender gender,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authRepository.getCurrentUserId();
      final email = _authRepository.getCurrentUserEmail();
      
      if (userId == null || email == null) {
        throw Exception('Utente non autenticato');
      }

      final profile = UserProfile(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        gender: gender,
        profilePicture: null,
        pictures: [],
      );

      await _profileRepository.createProfile(profile);
      
      _isLoading = false;
      _isProfileCreated = true;
      notifyListeners();
      
      // Call the callback if set
      _onProfileCreated?.call();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Handle error
    }
  }
}
