import 'package:flutter/material.dart';
import 'package:netshots/data/models/user_profile_model.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/image_storage_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImageStorageRepository _imageStorageRepository;
  UserProfile? _userProfile;
  bool _isLoading = false;

  ProfileViewModel(this._profileRepository, this._imageStorageRepository) {
    loadUserProfile();
  }

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isEmpty => _userProfile == null;

  Future<void> loadUserProfile() async {
    // Avoid reloading if profile is already loaded and not empty
    if (_userProfile != null && !_isLoading) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _profileRepository.getProfile();
    } catch (e) {
      // Handle error
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to force reload the profile (useful after profile creation/update)
  Future<void> forceReloadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _profileRepository.getProfile();
    } catch (e) {
      // Handle error
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _profileRepository.updateProfile(profile);
      _userProfile = profile;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _profileRepository.deleteProfile();
      _userProfile = null;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPicture(String tempImagePath) async {
    if (_userProfile == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Save the image to permanent storage
      final String permanentImagePath = await _imageStorageRepository.saveImage(tempImagePath);

      // Create a new list with the appended picture
      List<String> updatedPictures = List.from(_userProfile!.pictures);
      updatedPictures.add(permanentImagePath);

      // Create updated profile using copyWith
      final updatedProfile = _userProfile!.copyWith(
        pictures: updatedPictures,
      );

      // Update in repository and local state
      await _profileRepository.updateProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePicture(int index) async {
    if (_userProfile == null || index >= _userProfile!.pictures.length) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create a new list and get the image to delete
      List<String> updatedPictures = List.from(_userProfile!.pictures);
      String imageToDelete = updatedPictures[index];
      
      // Remove the picture from the list
      updatedPictures.removeAt(index);
      
      // Delete the image file from storage
      if (imageToDelete.isNotEmpty) {
        await _imageStorageRepository.deleteImage(imageToDelete);
      }
      
      // Create updated profile using copyWith
      final updatedProfile = _userProfile!.copyWith(
        pictures: updatedPictures,
      );
      
      // Update in repository and local state
      await _profileRepository.updateProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setProfilePicture(String tempImagePath) async {
    if (_userProfile == null) return;

    try {
      _isLoading = true;
      notifyListeners();

    final String permanentImagePath = await _imageStorageRepository.saveImage(tempImagePath);

      // Delete old profile picture if present
      final oldProfilePic = _userProfile!.profilePicture;
      if (oldProfilePic != null && oldProfilePic.isNotEmpty) {
  await _imageStorageRepository.deleteImage(oldProfilePic);
      }

      final updatedProfile = _userProfile!.copyWith(
        profilePicture: permanentImagePath,
      );

      await _profileRepository.updateProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeProfilePicture() async {
    if (_userProfile == null) return;

    final oldProfilePic = _userProfile!.profilePicture;
    if (oldProfilePic == null || oldProfilePic.isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

    await _imageStorageRepository.deleteImage(oldProfilePic);

      final updatedProfile = _userProfile!.copyWith(
        clearProfilePicture: true,
      );

      await _profileRepository.updateProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
