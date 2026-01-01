import 'package:flutter/material.dart';
import 'package:netshots/data/models/user_profile_model.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/models/match_model.dart';

class OtherUserProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final MatchRepository _matchRepository;
  final String userId;
  final Map<String, List<MatchModel>> _pictureMatches = {};

  OtherUserProfileViewModel(this._profileRepository, this._matchRepository, this.userId);

  UserProfile? _userProfile;
  List<String> _pictures = [];
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
        await _loadPicturesFromMatches();
      }
    } catch (e) {
      _errorMessage = 'Impossibile caricare il profilo';
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPicturesFromMatches() async {
    // Prefer the gallery derived from matches to align with the feed
    try {
      final matchPictures = await _matchRepository.getGalleryFromMatches(userId);
      if (matchPictures.isNotEmpty) {
        // Deduplicate while preserving order and drop empties/profile picture
        final seen = <String>{};
        _pictures = matchPictures
            .where((p) => p.isNotEmpty)
            .where((p) => p != _userProfile?.profilePicture)
            .where((p) => seen.add(p))
            .toList();
        return;
      }
    } catch (_) {
      // best-effort: fall back to profile pictures below
    }

    // Fallback: use stored profile pictures if available, but skip the profile picture itself
    final profilePics = _userProfile?.pictures ?? [];
    final seen = <String>{};
    _pictures = profilePics
        .where((p) => p.isNotEmpty)
        .where((p) => p != _userProfile?.profilePicture)
        .where((p) => seen.add(p))
        .toList();
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
