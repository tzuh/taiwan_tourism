import 'package:shared_preferences/shared_preferences.dart';
import 'package:taiwantourism/constants.dart';

class PreferenceHelper {
  static const String KEY_SHOW_EXPIRED_EVENTS = 'show_expired_events';
  static const String KEY_EVENT_SORT_BY = 'event_sort_by';

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> getShowExpiredEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_SHOW_EXPIRED_EVENTS) ??
        Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
  }

  static Future<void> setShowExpiredEvents(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEY_SHOW_EXPIRED_EVENTS, value);
  }

  static Future<int> getEventSortBy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_EVENT_SORT_BY) ?? Constants.PREF_DEF_EVENT_SORT_BY;
  }

  static Future<void> setEventSortBy(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(KEY_EVENT_SORT_BY, value);
  }
}
