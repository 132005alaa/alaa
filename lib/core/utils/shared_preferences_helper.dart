import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _profileImagePathKey = 'profile_image_path';
  static const String _appRatingKey = 'app_rating';

  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, path);
  }

  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImagePathKey);
  }

  static Future<void> saveAppRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_appRatingKey, rating);
  }

  static Future<double?> getAppRating() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_appRatingKey);
  }
}
