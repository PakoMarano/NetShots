import 'package:flutter/material.dart';
import 'package:netshots/data/models/user_profile_model.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/image_storage_repository.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/models/match_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImageStorageRepository _imageStorageRepository;
  final MatchRepository _matchRepository;

  UserProfile? _userProfile;
  bool _isLoading = false;
  List<String> _gallery = [];
  List<MatchModel> _galleryMatches = [];

  ProfileViewModel(this._profileRepository, this._imageStorageRepository, this._matchRepository) {
    loadUserProfile();
  }

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isEmpty => _userProfile == null;
  List<String> get gallery => _gallery;
  List<MatchModel> get galleryMatches => _galleryMatches;

  Future<void> loadUserProfile() async {
    // Avoid reloading if profile is already loaded and not empty
    if (_userProfile != null && !_isLoading) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _profileRepository.getProfile();
      // Load gallery derived from matches if we have a profile
      if (_userProfile != null) {
        await loadGallery();
      }
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

  Future<void> removePicture(int index) async {
    // Removing a gallery picture removes the match that contains it.
    if (_userProfile == null || index >= _gallery.length) return;

    try {
      _isLoading = true;
      notifyListeners();

      final imageToDelete = _gallery[index];

      // Find the match that owns this picture and delete it
      MatchModel? owner;
      if (_galleryMatches.isNotEmpty) {
        final list = _galleryMatches.where((m) => m.picture == imageToDelete).toList();
        if (list.isNotEmpty) owner = list.first;
      }
      if (owner == null) {
        final matches = await _matchRepository.getMatches(_userProfile!.userId);
        final matchList = matches.where((m) => m.picture == imageToDelete).toList();
        if (matchList.isNotEmpty) owner = matchList.first;
      }
      if (owner != null) {
        await _matchRepository.deleteMatch(owner.id);
      }

      // Delete the image file from storage
      if (imageToDelete.isNotEmpty) {
  await _imageStorageRepository.deleteImage(imageToDelete);
      }

      // Refresh gallery
      await loadGallery();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGallery({int? limit}) async {
    if (_userProfile == null) return;
    try {
      // Fetch full matches so we can show notes alongside pictures
      final matches = await _matchRepository.getMatches(_userProfile!.userId);
      // sort by date desc
      matches.sort((a, b) => b.date.compareTo(a.date));
      _galleryMatches = matches;
      final pictures = matches.map((m) => m.picture).where((p) => p.isNotEmpty).toList();
      _gallery = limit != null && pictures.length > limit ? pictures.sublist(0, limit) : pictures;
    } catch (e) {
      _gallery = [];
    }
    notifyListeners();
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
