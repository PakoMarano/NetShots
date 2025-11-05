import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/profile_repository.dart';

class DeleteProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  bool _isDeleting = false;

  DeleteProfileViewModel(this._profileRepository);

  bool get isDeleting => _isDeleting;

  Future<bool> deleteProfile() async {
    try {
      _isDeleting = true;
      notifyListeners();
      
      await _profileRepository.deleteProfile();
      
      _isDeleting = false;
      notifyListeners();
      
      return true; // Success
    } catch (e) {
      _isDeleting = false;
      notifyListeners();
      
      return false; // Failure
    }
  }
}
