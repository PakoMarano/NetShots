import 'package:flutter/material.dart';

class FollowRequestViewModel extends ChangeNotifier {
  List<FollowRequest> _followRequests = [];
  bool _isLoading = false;

  List<FollowRequest> get followRequests => _followRequests;
  bool get isLoading => _isLoading;
  bool get hasRequests => _followRequests.isNotEmpty;
  int get requestCount => _followRequests.length;

  FollowRequestViewModel() {
    loadFollowRequests();
  }

  Future<void> loadFollowRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate loading from API
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, return empty list (mock data)
      _followRequests = [];
    } catch (e) {
      // Handle error
      _followRequests = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptFollowRequest(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove the request from the list
      _followRequests.removeWhere((request) => request.userId == userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectFollowRequest(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove the request from the list
      _followRequests.removeWhere((request) => request.userId == userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRequests() async {
    await loadFollowRequests();
  }
}

class FollowRequest {
  final String userId;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final DateTime requestDate;

  FollowRequest({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.requestDate,
  });

  String get fullName => '$firstName $lastName';
}
