import 'package:shared_preferences/shared_preferences.dart';

// Save user ID to shared preferences
Future<void> saveUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId);
}

// Retrieve user ID from shared preferences
Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

// Clear user session data
Future<void> clearUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
