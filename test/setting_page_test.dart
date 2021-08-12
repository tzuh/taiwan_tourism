import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taiwantourism/constants.dart';
import 'package:taiwantourism/helper/preference_helper.dart';
import 'package:taiwantourism/setting_page.dart';

void main() {
  testWidgets('Preferences test', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: new SettingPage()),
    );
    await tester.pumpWidget(testWidget);
    // Initial values
    SharedPreferences.setMockInitialValues(<String, Object>{
      PreferenceHelper.KEY_SHOW_EXPIRED_EVENTS:
          Constants.PREF_DEF_SHOW_EXPIRED_EVENTS,
      PreferenceHelper.KEY_EVENT_SORT_BY: Constants.PREF_DEF_EVENT_SORT_BY,
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Test "Show Expired Events"
    await tester.tap(find.text(Constants.STRING_SHOW_EXPIRED_EVENTS));
    expect(prefs.getBool(PreferenceHelper.KEY_SHOW_EXPIRED_EVENTS),
        !Constants.PREF_DEF_SHOW_EXPIRED_EVENTS);
    // Test "Event Sort By"
    expect(
        (tester.widget(find.byKey(Key(Constants.STRING_ARRAY_EVENT_SORT_BY[
                Constants.PREF_DEF_EVENT_SORT_BY]!))) as DropdownMenuItem)
            .value,
        equals(Constants.PREF_DEF_EVENT_SORT_BY));
  });
}
