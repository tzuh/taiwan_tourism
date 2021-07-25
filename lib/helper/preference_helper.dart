import 'package:shared_preferences/shared_preferences.dart';
import 'package:taiwantourism/constants.dart';

class PreferenceHelper {
  static const String KEY_SHOW_EXPIRED_EVENTS = 'show_expired_events';

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> getShowExpiredEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_SHOW_EXPIRED_EVENTS) ??
        Constants.PREF_SHOW_EXPIRED_EVENTS;
  }

  static Future<void> setShowExpiredEvents(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEY_SHOW_EXPIRED_EVENTS, value);
  }
}
