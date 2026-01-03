import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/profile_repository.dart';

class StatsViewModel extends ChangeNotifier {
    final ProfileRepository _profileRepository;
    List<bool> _matchResults = [];
    List<int> _cumulativeScores = [];
    bool _isLoading = true;
    String? _errorMessage;

    StatsViewModel(this._profileRepository);

    List<bool> get matchResults => _matchResults;
    List<int> get cumulativeScores => _cumulativeScores;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    Future<void> fetchMatchResults(String userId) async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
            _matchResults = await _profileRepository.getMatchResults(userId);
            _buildCumulativeScores();
        } catch (e) {
            _errorMessage = 'Impossibile caricare le statistiche';
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }

    void _buildCumulativeScores() {
        int running = 0;
        _cumulativeScores = [];
        for (final result in _matchResults) {
            running += result ? 10 : -5;
            _cumulativeScores.add(running);
        }
    }
}