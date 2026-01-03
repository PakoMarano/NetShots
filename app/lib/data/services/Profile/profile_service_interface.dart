abstract class ProfileServiceInterface {
  Future<void> createProfile(Map<String, dynamic> profileData);
  Future<Map<String, dynamic>?> getProfile();
  Future<Map<String, dynamic>?> getProfileByUserId(String userId);
  Future<void> updateProfile(Map<String, dynamic> profileData);
  Future<void> deleteProfile();
  Future<List<bool>> getMatchResults(String userId);
}