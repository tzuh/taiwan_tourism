import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taiwantourism/event_page.dart';
import 'package:taiwantourism/model/activity_tourism_info.dart';
import 'package:taiwantourism/setting_page.dart';
import 'package:taiwantourism/util/network_util.dart';
import 'constants.dart';
import 'helper/preference_helper.dart';
import 'model/ptx_activity_tourism_info.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AlertStatus { NONE, IS_OFFLINE, SEVER_ERROR }

class HomePage extends StatefulWidget {
  final String currentCity;

  HomePage({required this.currentCity});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Directory _tempDir;
  List<ActivityTourismInfo> _eventList = <ActivityTourismInfo>[];
  List<ActivityTourismInfo> _eventListForDisplay = <ActivityTourismInfo>[];
  var _alertStatus = AlertStatus.NONE;
  bool _showExpiredEvents = Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
  int _eventSortBy = Constants.PREF_DEF_EVENT_SORT_BY;
  bool _showNoContent = false;

  @override
  void initState() {
    super.initState();
    initVariables().then((value) {
      NetworkUtil.isAvailable().then((isAvailable) {
        if (isAvailable) {
          getEvents(widget.currentCity);
        } else {
          _alertStatus = AlertStatus.IS_OFFLINE;
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    Future.delayed(Duration.zero, () {
      switch (_alertStatus) {
        case AlertStatus.IS_OFFLINE:
          showAlertDialog(context, Constants.STRING_OFFLINE,
              Constants.STRING_CHECK_CONNECTION);
          break;
        case AlertStatus.SEVER_ERROR:
          showAlertDialog(context, Constants.STRING_SEVER_ERROR,
              Constants.STRING_TRY_LATER);
          break;
        default:
          break;
      }
      _alertStatus = AlertStatus.NONE;
    });

    return Scaffold(
      backgroundColor: Constants.COLOR_THEME_DARK_WHITE,
      appBar: AppBar(
        elevation: 0,
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
        title: TextButton(
            onPressed: () {},
            child: Text(
              Constants.CITY_NAMES[widget.currentCity].toString(),
              style:
                  TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 20.0),
            )),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Constants.COLOR_THEME_WHITE,
              size: 24,
            ),
            tooltip: Constants.STRING_SETTINGS,
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingPage()))
                  .then((value) {
                PreferenceHelper.getPrefs().then((prefs) {
                  var showExpiredEvents =
                      prefs.getBool(PreferenceHelper.KEY_SHOW_EXPIRED_EVENTS) ??
                          Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
                  var eventSortBy =
                      prefs.getInt(PreferenceHelper.KEY_EVENT_SORT_BY) ??
                          Constants.PREF_DEF_EVENT_SORT_BY;
                  if ((_showExpiredEvents != showExpiredEvents) ||
                      (_eventSortBy != eventSortBy)) {
                    _showExpiredEvents = showExpiredEvents;
                    _eventSortBy = eventSortBy;
                    sortEventsBySetting();
                    setState(() {});
                  }
                });
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(children: [
              ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                  itemCount: _eventListForDisplay.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isExpired = _eventListForDisplay[index]
                        .endTime
                        .isBefore(DateTime.now().toUtc());
                    var localStartTime =
                        _eventListForDisplay[index].startTime.toLocal();
                    int startDurationInDays = DateTime(localStartTime.year,
                                localStartTime.month, localStartTime.day)
                            .difference(DateTime.now())
                            .inDays +
                        1;
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventPage(
                                        event: _eventListForDisplay[index],
                                        tempDir: _tempDir,
                                      ))).then((value) => setState(() {}));
                        },
                        child: Container(
                          height: screenWidth * 0.63,
                          margin: EdgeInsets.symmetric(
                              horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                              vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Constants.COLOR_THEME_WHITE,
                              width: 1,
                            ),
                            image: DecorationImage(
                              image: _eventListForDisplay[index]
                                      .picture
                                      .pictureUrl1
                                      .isNotEmpty
                                  ? NetworkToFileImage(
                                      url: _eventListForDisplay[index]
                                          .picture
                                          .pictureUrl1,
                                      file: File(join(_tempDir.path,
                                          '${_eventListForDisplay[index].id}_a1.jpg')),
                                      debug: false,
                                    )
                                  : Image.asset('assets/images/card_bg.jpg')
                                      .image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: screenWidth * 0.25,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)),
                                    gradient: LinearGradient(
                                      begin: const Alignment(0.0, -1.0),
                                      end: const Alignment(0.0, 1.0),
                                      colors: <Color>[
                                        const Color(0x00000000),
                                        const Color(0x30000000),
                                        const Color(0x50000000),
                                        const Color(0x90000000),
                                      ],
                                      stops: [
                                        0.0,
                                        0.2,
                                        0.4,
                                        1.0,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                                    vertical: Constants.DIMEN_PRIMARY_MARGIN),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_eventListForDisplay[index].name}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          backgroundColor: Colors.transparent),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      _eventListForDisplay[index].location,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          backgroundColor: Colors.transparent),
                                      maxLines: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getEventDateString(
                                              _eventListForDisplay[index]
                                                  .startTime,
                                              _eventListForDisplay[index]
                                                  .endTime),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: isExpired
                                                  ? Constants.COLOR_THEME_RED
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          maxLines: 1,
                                        ),
                                        Text(
                                          isExpired
                                              ? Constants.STRING_EVENT_EXPIRED
                                              : (startDurationInDays >= 1)
                                                  ? (startDurationInDays ~/ 7 >
                                                          0)
                                                      ? '${startDurationInDays ~/ 7}${Constants.STRING_BEGIN_AFTER_WEEKS}'
                                                      : '$startDurationInDays${Constants.STRING_BEGIN_AFTER_DAYS}'
                                                  : '${Constants.STRING_EVENT_RUNNING}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: isExpired
                                                  ? Constants.COLOR_THEME_RED
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ));
                  }),
              Visibility(
                visible: _showNoContent,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    Constants.STRING_NO_SUITABLE_CONTENT,
                    style: TextStyle(
                      fontSize: 16,
                      color: Constants.COLOR_THEME_BLACK,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ]),
          ),
          Visibility(
            visible: false,
            child: Container(
              padding: EdgeInsets.all(Constants.DIMEN_PRIMARY_MARGIN / 2),
              width: double.infinity,
              color: Constants.COLOR_THEME_BLUE_GREY,
              alignment: Alignment.center,
              child: Text(
                '${Constants.STRING_PTX}',
                style: TextStyle(
                  fontSize: 12,
                  color: Constants.COLOR_THEME_WHITE,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> initVariables() async {
    _tempDir = await getTemporaryDirectory();
    _showExpiredEvents = await PreferenceHelper.getShowExpiredEvents();
    _eventSortBy = await PreferenceHelper.getEventSortBy();
  }

  void getEvents(String city) {
    getPtxDataByCity(city).then((response) {
      print('PTX status code: ${response.statusCode}');
      if (response.statusCode == Constants.HTTP_STATUS_CODE_OK) {
        // Parse data
        List<PtxActivityTourismInfo> list = List<PtxActivityTourismInfo>.from(
            json
                .decode(response.body)
                .map((s) => PtxActivityTourismInfo.fromJson(s)));
        // Remove duplicate data
        List<ActivityTourismInfo> rawEventList = <ActivityTourismInfo>[];
        var checkedList = Map<String, DateTime>();
        list.forEach((ptx) {
          var event = ActivityTourismInfo.fromPtx(ptx);
          rawEventList.add(event);
          if (checkedList.containsKey(event.id)) {
            if (checkedList[event.id]!.isBefore(event.updateTime)) {
              checkedList[event.id] = event.updateTime;
            }
          } else {
            checkedList[event.id] = event.updateTime;
          }
        });
        _eventList.clear();
        rawEventList.forEach((event) {
          if (checkedList[event.id]!.isAtSameMomentAs(event.updateTime)) {
            _eventList.add(event);
          }
        });
        checkedList.clear();
        rawEventList.clear();
        sortEventsBySetting();
      } else {
        // Failed to get PTX data due to unknown error
        _alertStatus = AlertStatus.SEVER_ERROR;
      }
      setState(() {});
    });
  }

  void sortEventsBySetting() {
    _eventListForDisplay.clear();
    List<ActivityTourismInfo> oldEventList = <ActivityTourismInfo>[];
    List<ActivityTourismInfo> newEventList = <ActivityTourismInfo>[];
    DateTime now = DateTime.now().toUtc();
    _eventList.forEach((event) {
      if (event.endTime.isBefore(now)) {
        oldEventList.add(event);
      } else {
        newEventList.add(event);
      }
    });
    switch (_eventSortBy) {
      case Constants.EVENT_SORT_BY_START_TIME:
        newEventList.sort((a, b) => a.startTime.isAfter(b.startTime) ? 1 : -1);
        if (_showExpiredEvents) {
          oldEventList
              .sort((a, b) => a.startTime.isBefore(b.startTime) ? 1 : -1);
        }
        break;
      case Constants.EVENT_SORT_BY_END_TIME:
        newEventList.sort((a, b) => a.endTime.isAfter(b.endTime) ? 1 : -1);
        if (_showExpiredEvents) {
          oldEventList.sort((a, b) => a.endTime.isBefore(b.endTime) ? 1 : -1);
        }
        break;
    }
    _eventListForDisplay = newEventList;
    if (_showExpiredEvents) {
      _eventListForDisplay += oldEventList;
    }
    _showNoContent = _eventListForDisplay.length == 0;
  }

  showAlertDialog(BuildContext context, String title, String content) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(Constants.STRING_OK),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String codec(String str1, String str2) {
    List<int> list1 = base64.decode(str1);
    List<int> list2 = base64.decode(str2);
    List<int> result = [];
    for (int i = 0; i < list1.length; i++) {
      result.add(list1[i] ^ list2[i]);
    }
    return base64.encode(result);
  }

  Future<Response> getPtxDataByCity(String city) async {
    var envU = dotenv.env['PTX_U'].toString();
    var envK = dotenv.env['PTX_K'].toString();
    var k = utf8.encode(envK.substring(0, 3) +
        codec(envK.substring(3), 's7vKtxHFA3EpBryNI3AH1e9K'));
    var utcTime =
        DateFormat('EEE, dd MMM y HH:mm:ss').format(DateTime.now().toUtc());
    var signature = base64.encode(
        Hmac(sha1, k).convert(utf8.encode('x-date: $utcTime GMT')).bytes);

    return await http.get(
        Uri.parse(
            'https://ptx.transportdata.tw/MOTC/v2/Tourism/Activity/$city?\$orderby=EndTime%20desc&\$top=20&\$format=JSON'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization':
              'hmac username="$envU", algorithm="hmac-sha1", headers="x-date", signature="$signature"',
          'x-date': '$utcTime GMT',
          'Accept-Encoding': 'gzip'
        });
  }

  String getEventDateString(DateTime startDateTime, DateTime endDateTime) {
    var localStartDateTime = startDateTime.toLocal();
    var localEndDateTime = endDateTime.toLocal();
    var duration = endDateTime.difference(startDateTime).inSeconds;
    int quotient = duration ~/ 86400;
    int remainder = duration % 86400;
    if (localStartDateTime.hour == 0 &&
        localStartDateTime.minute == 0 &&
        remainder == 0) {
      // 全日活動
      if (quotient <= 1) {
        // 單日活動，僅顯示開始日期。
        return '${DateFormat('yyyy/M/d').format(localStartDateTime)}';
      } else {
        // 多日活動，結束日期減一日顯示。
        return '${DateFormat('yyyy/M/d').format(localStartDateTime)} - ${DateFormat('yyyy/M/d').format(localEndDateTime.add(Duration(days: -1)))}';
      }
    } else {
      // 非全日活動
      if (localStartDateTime.year == localEndDateTime.year &&
          localStartDateTime.month == localEndDateTime.month &&
          localStartDateTime.day == localEndDateTime.day) {
        // 同日活動
        return '${DateFormat('yyyy/M/d').format(localStartDateTime)}';
      } else {
        // 多日活動
        return '${DateFormat('yyyy/M/d').format(localStartDateTime)} - ${DateFormat('yyyy/M/d').format(localEndDateTime)}';
      }
    }
  }
}
