import 'package:netshots/data/services/profile/profile_service_interface.dart';
import 'package:netshots/data/models/user_profile_model.dart';

class ProfileRepository {
  final ProfileServiceInterface _profileService; 

  ProfileRepository(this._profileService);

  Future<void> createProfile(UserProfile profile) async {
    await _profileService.createProfile(profile.toMap());
  }

  Future<UserProfile?> getProfile() async {
    final profileMap = await _profileService.getProfile();
    if (profileMap == null) return null;
    return UserProfile.fromMap(profileMap);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _profileService.updateProfile(profile.toMap());
  }

  Future<void> deleteProfile() async {
    await _profileService.deleteProfile();
  }
}