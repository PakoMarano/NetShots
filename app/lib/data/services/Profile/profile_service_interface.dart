abstract class ProfileServiceInterface {
  Future<void> createProfile(Map<String, dynamic> profileData);
  Future<Map<String, dynamic>?> getProfile();
  Future<void> updateProfile(Map<String, dynamic> profileData);
  Future<void> deleteProfile();
}