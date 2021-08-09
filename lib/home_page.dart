import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taiwantourism/event_page.dart';
import 'package:taiwantourism/model/event_model.dart';
import 'package:taiwantourism/setting_page.dart';
import 'package:taiwantourism/util/network_util.dart';
import 'constants.dart';
import 'helper/database_helper.dart';
import 'helper/preference_helper.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

enum AlertStatus { NONE, IS_OFFLINE, SEVER_ERROR }

class HomePage extends StatefulWidget {
  final String currentCity;
  final Directory tempDir;

  HomePage({required this.currentCity, required this.tempDir});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EventModel> _eventList = <EventModel>[];
  List<EventModel> _eventListForDisplay = <EventModel>[];
  var _alertStatus = AlertStatus.NONE;
  bool _showExpiredEvents = Constants.PREF_DEF_SHOW_EXPIRED_EVENTS;
  int _eventSortBy = Constants.PREF_DEF_EVENT_SORT_BY;
  bool _showNoContent = false;

  @override
  void initState() {
    super.initState();
    initVariables().then((_) {
      NetworkUtil.isAvailable().then((isAvailable) {
        if (isAvailable) {
          getEventsByCity(widget.currentCity);
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
              Constants.CITY_ID_TO_STRING[widget.currentCity].toString(),
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
                    var thisEvent = _eventListForDisplay[index];
                    var now = DateTime.now();
                    bool isExpired = thisEvent.endTime.isBefore(now.toUtc());
                    var localStartTime = thisEvent.startTime.toLocal();
                    int startDurationInDays = DateTime(localStartTime.year,
                            localStartTime.month, localStartTime.day)
                        .difference(DateTime(now.year, now.month, now.day))
                        .inDays;
                    bool hasImage1 =
                        thisEvent.picture.ptxPictureList.length >= 1 &&
                            thisEvent.picture.ptxPictureList[0].url.isNotEmpty;
                    return InkWell(
                        onTap: () {
                          _eventListForDisplay[index].status =
                              Constants.EVENT_STATUS_NONE;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventPage(
                                event: thisEvent,
                                tempDir: widget.tempDir,
                              ),
                            ),
                          ).then(
                            (value) => setState(() {}),
                          );
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
                              image: hasImage1
                                  ? NetworkToFileImage(
                                      url: thisEvent
                                          .picture.ptxPictureList[0].url,
                                      file: File(join(widget.tempDir.path,
                                          '${thisEvent.srcId}_${thisEvent.srcType}1.jpg')),
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
                                      '${thisEvent.name}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          backgroundColor: Colors.transparent),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      thisEvent.location,
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
                                              thisEvent.startTime,
                                              thisEvent.endTime),
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
                              ),
                              Visibility(
                                visible: thisEvent.status ==
                                    Constants.EVENT_STATUS_NEW,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: Constants.DIMEN_PRIMARY_MARGIN,
                                      left: Constants.DIMEN_PRIMARY_MARGIN),
                                  padding: EdgeInsets.all(
                                      Constants.DIMEN_PRIMARY_MARGIN / 3),
                                  decoration: BoxDecoration(
                                    color: Constants.COLOR_THEME_RED,
                                    border: Border.all(
                                        color: Constants.COLOR_THEME_WHITE,
                                        width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            8) //         <--- border radius here
                                        ),
                                  ),
                                  child: Text(
                                    Constants.STRING_NEW,
                                    style: TextStyle(
                                        color: Constants.COLOR_THEME_WHITE,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
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
            visible: true,
            child: Container(
              padding: EdgeInsets.all(Constants.DIMEN_PRIMARY_MARGIN / 2),
              width: double.infinity,
              color: Constants.COLOR_THEME_BLUE_GREY,
              alignment: Alignment.center,
              child: Text(
                '${Constants.STRING_DISCLAIMER}',
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
    _showExpiredEvents = await PreferenceHelper.getShowExpiredEvents();
    _eventSortBy = await PreferenceHelper.getEventSortBy();
  }

  void getEventsByCity(String cityId) {
    DatabaseHelper.dh
        .getEventsByCity(Constants.SOURCE_PTX, cityId)
        .then((value) {
      _eventList.clear();
      _eventList = value;
      sortEventsBySetting();
      setState(() {});
    });
  }

  void sortEventsBySetting() {
    _eventListForDisplay.clear();
    List<EventModel> oldEventList = <EventModel>[];
    List<EventModel> newEventList = <EventModel>[];
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
    AlertDialog dialog = AlertDialog(
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
      context: context,
      barrierColor: Constants.COLOR_THEME_TRANSPARENT_BLACK,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return dialog;
      },
    );
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
