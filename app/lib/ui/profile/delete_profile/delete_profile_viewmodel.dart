import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/profile_repository.dart';

class DeleteProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  bool _isDeleting = false;
  bool _isDeleted = false;
  String? _errorMessage;

  DeleteProfileViewModel(this._profileRepository);

  bool get isDeleting => _isDeleting;
  bool get isDeleted => _isDeleted;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteProfile() async {
    try {
      _isDeleting = true;
      _errorMessage = null;
      notifyListeners();
      
      await _profileRepository.deleteProfile();
      
      _isDeleting = false;
      _isDeleted = true;
      notifyListeners();
    } catch (e) {
      _isDeleting = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
