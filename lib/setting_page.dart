import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'helper/preference_helper.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _showExpiredEvents = Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
  int _eventSortBy = Constants.PREF_DEF_EVENT_SORT_BY;
  String _version = '';

  @override
  void initState() {
    super.initState();
    initVariables().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.COLOR_THEME_DARK_WHITE,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Constants.COLOR_THEME_WHITE,
                  size: 24,
                ),
                tooltip: Constants.STRING_BACK,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(Constants.STRING_SETTINGS),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              child: SwitchListTile(
                value: _showExpiredEvents,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Constants.DIMEN_PRIMARY_MARGIN,
                    horizontal: Constants.DIMEN_PRIMARY_MARGIN * 2),
                title: Text(
                  Constants.STRING_SHOW_EXPIRED_EVENTS,
                  style: TextStyle(
                      fontSize: 16, color: Constants.COLOR_THEME_BLACK),
                  textAlign: TextAlign.start,
                ),
                onChanged: (value) {
                  setState(() {
                    _showExpiredEvents = value;
                    PreferenceHelper.setShowExpiredEvents(_showExpiredEvents);
                  });
                },
              ),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(
                  horizontal: Constants.DIMEN_PRIMARY_MARGIN * 2),
              color: Constants.COLOR_THEME_WHITE,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: Constants.DIMEN_PRIMARY_MARGIN,
                  horizontal: Constants.DIMEN_PRIMARY_MARGIN * 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: _eventSortBy,
                  items: [
                    DropdownMenuItem(
                      child: Text(Constants.STRING_SORT_BY_START_TIME),
                      value: Constants.EVENT_SORT_BY_START_TIME,
                    ),
                    DropdownMenuItem(
                      child: Text(Constants.STRING_SORT_BY_END_TIME),
                      value: Constants.EVENT_SORT_BY_END_TIME,
                    )
                  ],
                  onChanged: (value) {
                    setState(() {
                      _eventSortBy = value as int;
                      PreferenceHelper.setEventSortBy(_eventSortBy);
                    });
                  },
                  style: TextStyle(
                      fontSize: 16, color: Constants.COLOR_THEME_BLACK),
                  icon: Icon(Icons.arrow_drop_down, size: 30),
                  iconEnabledColor: Constants.COLOR_THEME_BLUE_GREY,
                  isExpanded: true,
                  elevation: 4,
                  dropdownColor: Constants.COLOR_THEME_DARK_WHITE,
                ),
              ),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(
                  horizontal: Constants.DIMEN_PRIMARY_MARGIN * 2),
              color: Constants.COLOR_THEME_WHITE,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                  vertical: Constants.DIMEN_PRIMARY_MARGIN * 2),
              child: Column(
                children: [
                  Text(Constants.STRING_APP_VERSION,
                      style: TextStyle(
                        fontSize: 20,
                        color: Constants.COLOR_THEME_BLACK,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center),
                  Text('$_version',
                      style: TextStyle(
                        fontSize: 16,
                        color: Constants.COLOR_THEME_BLACK,
                      ),
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                  vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
              child: Column(
                children: [
                  Text(Constants.STRING_REFERENCES,
                      style: TextStyle(
                        fontSize: 20,
                        color: Constants.COLOR_THEME_BLACK,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center),
                  GestureDetector(
                    onTap: () async {
                      await canLaunch(Constants.LINK_PTX)
                          ? await launch(Constants.LINK_PTX)
                          : throw 'Could not launch ${Constants.LINK_PTX}';
                    }, // handle your image tap here
                    child: Container(
                      width: screenWidth * 0.6,
                      child: Image.asset(
                        'assets/images/ptx_logo.png',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initVariables() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _showExpiredEvents = await PreferenceHelper.getShowExpiredEvents();
    _eventSortBy = await PreferenceHelper.getEventSortBy();
  }
}
