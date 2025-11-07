import 'package:flutter/material.dart';
import 'package:netshots/data/models/match_model.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/repositories/image_storage_repository.dart';
import 'package:netshots/data/repositories/profile_repository.dart';

class AddMatchViewModel extends ChangeNotifier {
  final MatchRepository _matchRepository;
  final ImageStorageRepository _imageStorageRepository;
  final ProfileRepository _profileRepository;

  bool _isSubmitting = false;

  AddMatchViewModel(this._matchRepository, this._imageStorageRepository, this._profileRepository);

  bool get isSubmitting => _isSubmitting;

  Future<bool> submitMatch({
    required String imagePath,
    required bool isVictory,
    required DateTime date,
    String? notes,
  }) async {
    if (imagePath.isEmpty) return false;
    _isSubmitting = true;
    notifyListeners();

    try {
      final profile = await _profileRepository.getProfile();
      if (profile == null) throw Exception('User profile not found');

      final permanent = await _imageStorageRepository.saveImage(imagePath);

      final match = MatchModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: profile.userId,
        isVictory: isVictory,
        date: date,
        picture: permanent,
        notes: notes,
      );

      await _matchRepository.addMatch(match);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
