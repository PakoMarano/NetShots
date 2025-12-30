import 'package:flutter/material.dart';
import 'package:netshots/data/models/user_profile_model.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/models/match_model.dart';

class OtherUserProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final MatchRepository _matchRepository;
  final String userId;

  OtherUserProfileViewModel(this._profileRepository, this._matchRepository, this.userId);

  UserProfile? _userProfile;
  List<String> _pictures = [];
  Map<String, List<MatchModel>> _pictureMatches = {};
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  List<String> get pictures => _pictures;
  Map<String, List<MatchModel>> get pictureMatches => _pictureMatches;
  bool get isLoading => _isLoading;
  bool get isEmpty => _userProfile == null;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _profileRepository.getProfileByUserId(userId);
      
      if (_userProfile != null) {
        // Build the pictures array from profile
        _buildPictures();
      }
    } catch (e) {
      _errorMessage = 'Impossibile caricare il profilo';
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _buildPictures() {
    if (_userProfile == null) return;
    
    _pictures = [];
    if (_userProfile!.profilePicture != null && _userProfile!.profilePicture!.isNotEmpty) {
      _pictures.add(_userProfile!.profilePicture!);
    }
    _pictures.addAll(_userProfile!.pictures);
  }

  Future<void> loadMatchesForPhoto(int index) async {
    if (_userProfile == null || index >= _pictures.length) return;

    final picture = _pictures[index];
    // Check if already loaded
    if (_pictureMatches.containsKey(picture)) {
      return;
    }

    try {
      final matches = await _matchRepository.getMatches(userId);
      final filtered = matches.where((m) => m.picture == picture).toList();
      _pictureMatches[picture] = filtered;
      notifyListeners();
    } catch (e) {
      // If error, just leave empty
      _pictureMatches[picture] = [];
    }
  }
}
