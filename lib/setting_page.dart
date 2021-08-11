import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'helper/database_helper.dart';
import 'helper/preference_helper.dart';
import 'package:path/path.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _showExpiredEvents = Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
  int _eventSortBy = Constants.PREF_DEF_EVENT_SORT_BY;
  PackageInfo? _packageInfo;
  int _reportCounter = 0;

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
                      ),
                      textAlign: TextAlign.center),
                  GestureDetector(
                    onTap: () async {
                      if (_reportCounter >= 5) {
                        _reportCounter = 0;
                        sendReport();
                      } else {
                        _reportCounter++;
                      }
                    },
                    child: Text(
                        '${_packageInfo != null ? _packageInfo!.version : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Constants.COLOR_THEME_BLACK,
                        ),
                        textAlign: TextAlign.center),
                  ),
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
                      ),
                      textAlign: TextAlign.center),
                  GestureDetector(
                    onTap: () async {
                      await canLaunch(Constants.LINK_PTX)
                          ? await launch(Constants.LINK_PTX)
                          : throw 'Could not launch ${Constants.LINK_PTX}';
                    },
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
    _packageInfo = await PackageInfo.fromPlatform();
    _showExpiredEvents = await PreferenceHelper.getShowExpiredEvents();
    _eventSortBy = await PreferenceHelper.getEventSortBy();
  }

  Future<void> sendReport() async {
    // Prepare database file
    String attachmentPath = '';
    Directory? appDocDir;
    if (Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    }
    print('appDocDir: $appDocDir');
    if (appDocDir != null) {
      String dbUrl =
          join(await getDatabasesPath(), DatabaseHelper.DATABASE_NAME);
      print('dbUrl: $dbUrl');
      await DatabaseHelper.dh.closeDatabase();
      attachmentPath = join(appDocDir.path, DatabaseHelper.DATABASE_NAME);
      await File(dbUrl).copy(attachmentPath);
    }
    // Get the device info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var now = DateTime.now();
    var time = DateFormat(Constants.EXPRESSION_DISPLAY).format(now);
    var tOffset = now.timeZoneOffset.inHours;
    String deviceInfoStr = '';
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceInfoStr = '軟體名稱：${_packageInfo!.appName}';
      deviceInfoStr += '\n軟體版本：${_packageInfo!.version}';
      deviceInfoStr += '\n裝置名稱：${androidInfo.brand} (${androidInfo.model})';
      deviceInfoStr +=
          '\n系統版本：${androidInfo.version.release} (${androidInfo.version.sdkInt})';
      deviceInfoStr += '\n時間：$time (UTC${tOffset >= 0 ? '+' : ''}$tOffset)';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceInfoStr = '軟體名稱：${_packageInfo!.appName}';
      deviceInfoStr += '\n軟體版本：${_packageInfo!.version}';
      deviceInfoStr += '\n裝置名稱：${iosInfo.name}(${iosInfo.model})';
      deviceInfoStr += '\n系統版本：${iosInfo.systemVersion}';
      deviceInfoStr += '\n時間：$time (UTC${tOffset >= 0 ? '+' : ''}$tOffset))';
      print('Running on ${iosInfo.utsname.machine}');
    }
    deviceInfoStr += '\n';
    deviceInfoStr += '\n(本信件並不會收集您的隱私資訊，感謝您的回饋讓此軟體有機會更好。)';
    deviceInfoStr += '\n\n';

    final email = Email(
      subject: '[錯誤回報] ${_packageInfo!.appName}',
      body: deviceInfoStr,
      recipients: ['keydigit@gmail.com'],
      attachmentPaths: [attachmentPath],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }
}
