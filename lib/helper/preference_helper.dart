import 'package:shared_preferences/shared_preferences.dart';
import 'package:taiwantourism/constants.dart';

class PreferenceHelper {
  static const String KEY_PTX_LAST_MODIFIED_TIME = 'ptx_last_modified_time';
  static const String KEY_TDX_LAST_MODIFIED_TIME = 'tdx_last_modified_time';
  static const String KEY_TDX_ACCESS_TOKEN = 'tdx_access_token';
  static const String KEY_SHOW_EXPIRED_EVENTS = 'show_expired_events';
  static const String KEY_EVENT_SORT_BY = 'event_sort_by';

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<String> getPtxLastModifiedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_PTX_LAST_MODIFIED_TIME) ?? '';
  }

  static Future<void> setPtxLastModifiedTime(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_PTX_LAST_MODIFIED_TIME, value);
  }

  static Future<String> getTdxLastModifiedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_TDX_LAST_MODIFIED_TIME) ?? '';
  }

  static Future<void> setTdxLastModifiedTime(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_TDX_LAST_MODIFIED_TIME, value);
  }

  static Future<String> getTdxAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_TDX_ACCESS_TOKEN) ?? '';
  }

  static Future<void> setTdxAccessToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_TDX_ACCESS_TOKEN, value);
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
