import 'package:shared_preferences/shared_preferences.dart';

class SessionManagerLogin {
  static const int _sessionDurationDays = 1;

  Future<bool> isSessionValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timestampString = prefs.getString('loginTimestamp');
    if (timestampString != null) {
      DateTime loginTimestamp = DateTime.parse(timestampString);
      DateTime now = DateTime.now();
      if (now.difference(loginTimestamp).inMinutes >= _sessionDurationDays) {
        return false;
      }
    }
    return true;
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginTimestamp');
    await prefs.remove('token');
    await prefs.remove('isLoggedIn');
  }
}
