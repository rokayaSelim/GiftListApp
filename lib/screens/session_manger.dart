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
// Save the friendId to shared preferences
Future<void> saveFriendId(int friendId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('friendId', friendId);
}
// Retrieve the friend ID from shared preferences
Future<int?> getFriendId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('friendId');
}
// Save the eventId to shared preferences
Future<void> saveEventId(int eventId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('eventId', eventId);
}

// Retrieve the eventId from shared preferences
Future<int> getEventId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('eventId') ?? 0; // Default to 0 if no eventId is saved
}


// Clear user session data
Future<void> clearUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
