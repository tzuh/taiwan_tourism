import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taiwantourism/helper/preference_helper.dart';
import 'package:taiwantourism/util/network_util.dart';

import 'constants.dart';
import 'helper/database_helper.dart';
import 'helper/ptx_helper.dart';
import 'home_page.dart';
import 'model/event_model.dart';
import 'model/ptx_activity_tourism_info.dart';

enum AlertStatus {
  NONE,
  LOCK,
  IS_ONLINE,
  IS_OFFLINE,
  IS_PROGRESSING,
  SEVER_ERROR,
}

class SelectionPage extends StatefulWidget {
  SelectionPage();

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  var _ptxLocalEventList = <EventModel>[];
  var _ptxSeverEventList = <EventModel>[];
  var _counterList = Map<String, int>();
  var _alertStatus = AlertStatus.NONE;
  var _lastPressedBackButton = DateTime.now()
      .toUtc()
      .add(Duration(seconds: -Constants.SECONDS_FOR_QUIT));
  late double _screenDiagonal;
  late double _scale;
  late StateSetter _setProgressDialogState;
  double _progress = -1.0;
  String _progressMessage = Constants.STRING_CHECKING_DATA;
  String _ptxLastModifiedTime = '';

  @override
  void initState() {
    super.initState();
    setState(() => _alertStatus = AlertStatus.LOCK);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    _screenDiagonal = sqrt(pow(screenHeight, 2) + pow(screenWidth, 2));
    _scale = _screenDiagonal / 900;

    Future.delayed(Duration.zero, () {
      switch (_alertStatus) {
        case AlertStatus.LOCK:
          showProgressDialog(context);
          prepareData();
          break;
        case AlertStatus.IS_OFFLINE:
          showAlertDialog(context, Constants.STRING_OFFLINE,
              Constants.STRING_CHECK_CONNECTION);
          _alertStatus = AlertStatus.NONE;
          break;
        case AlertStatus.SEVER_ERROR:
          showAlertDialog(context, Constants.STRING_SEVER_ERROR,
              Constants.STRING_TRY_LATER);
          _alertStatus = AlertStatus.NONE;
          break;
        default:
          break;
      }
    });

    return WillPopScope(
        onWillPop: () async {
          var now = DateTime.now().toUtc();
          if (now.difference(_lastPressedBackButton).inSeconds >
              Constants.SECONDS_FOR_QUIT) {
            _lastPressedBackButton = now;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Constants.STRING_PRESS_AGAIN_TO_QUIT)));
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Constants.COLOR_THEME_BLUE_GREY,
          body: Container(
              margin: EdgeInsets.symmetric(vertical: screenHeight / 30),
              decoration: BoxDecoration(
                color: Constants.COLOR_THEME_BLUE_GREY,
                image: DecorationImage(
                  image: AssetImage('assets/images/selection_bg.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07,
                      top: screenHeight * 0.01,
                      bottom: screenHeight * 0.00),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAOYUAN]
                                      .toString(),
                                  Constants.TAOYUAN),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HSINCHU]
                                      .toString(),
                                  Constants.HSINCHU),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HSINCHU_COUNTY]
                                      .toString(),
                                  Constants.HSINCHU_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.MIAOLI_COUNTY]
                                      .toString(),
                                  Constants.MIAOLI_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAICHUNG]
                                      .toString(),
                                  Constants.TAICHUNG),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.CHANGHUA_COUNTY]
                                      .toString(),
                                  Constants.CHANGHUA_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.YUNLIN_COUNTY]
                                      .toString(),
                                  Constants.YUNLIN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.CHIAYI]
                                      .toString(),
                                  Constants.CHIAYI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.CHIAYI_COUNTY]
                                      .toString(),
                                  Constants.CHIAYI_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAINAN]
                                      .toString(),
                                  Constants.TAINAN),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KAOHSIUNG]
                                      .toString(),
                                  Constants.KAOHSIUNG),
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KEELUNG]
                                      .toString(),
                                  Constants.KEELUNG),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAIPEI]
                                      .toString(),
                                  Constants.TAIPEI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.NEW_TAIPEI]
                                      .toString(),
                                  Constants.NEW_TAIPEI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.YILAN_COUNTY]
                                      .toString(),
                                  Constants.YILAN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HUALIEN_COUNTY]
                                      .toString(),
                                  Constants.HUALIEN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.NANTOU_COUNTY]
                                      .toString(),
                                  Constants.NANTOU_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAITUNG_COUNTY]
                                      .toString(),
                                  Constants.TAITUNG_COUNTY),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.PINGTUNG_COUNTY]
                                      .toString(),
                                  Constants.PINGTUNG_COUNTY),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.LIENCHIANG_COUNTY]
                                      .toString(),
                                  Constants.LIENCHIANG_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KINMEN_COUNTY]
                                      .toString(),
                                  Constants.KINMEN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.PENGHU_COUNTY]
                                      .toString(),
                                  Constants.PENGHU_COUNTY),
                            ]),
                      ]))),
        ));
  }

  showProgressDialog(BuildContext context) {
    var dialog = Material(
      color: Constants.COLOR_TRANSPARENT,
      child: StatefulBuilder(builder: (context, setState) {
        _setProgressDialogState = setState;
        return SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                _progressMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Constants.COLOR_THEME_WHITE,
                ),
                textAlign: TextAlign.center,
              ),
              Visibility(
                visible: _progress >= 0,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: Constants.DIMEN_PRIMARY_MARGIN,
                      horizontal: Constants.DIMEN_PRIMARY_MARGIN * 2),
                  child: LinearProgressIndicator(
                    backgroundColor: Constants.COLOR_THEME_BLUE_GREY,
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Constants.COLOR_THEME_WHITE),
                    value: _progress,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
    showGeneralDialog(
      context: context,
      barrierColor: Constants.COLOR_THEME_TRANSPARENT_BLACK,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return dialog;
      },
    );
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

  void prepareData() {
    NetworkUtil.isAvailable().then((isOnline) {
      if (isOnline) {
        _alertStatus = AlertStatus.IS_ONLINE;
        getEventsFromDatabase().then((_) {
          print('Number of PTX local events: ${_ptxLocalEventList.length}');
          PtxHelper.getPtxEvents(300).then((response) {
            print('PTX status code: ${response.statusCode}');
            if (response.statusCode == Constants.PTX_STATUS_CODE_OK) {
              _ptxLastModifiedTime = response
                  .headers[Constants.PTX_RESPONSE_HEADER_LAST_MODIFIED]
                  .toString();
              _progressMessage = Constants.STRING_UPDATING_DATA;
              _setProgressDialogState(() => _progress = 0.0);
              // Parse data
              List<PtxActivityTourismInfo> list =
                  List<PtxActivityTourismInfo>.from(json
                      .decode(response.body)
                      .map((s) => PtxActivityTourismInfo.fromJson(s)));
              // Prepare sever data and remove useless data
              List<EventModel> ptxRawEventList = <EventModel>[];
              var checkedList = Map<String, DateTime>();
              list.forEach((ptx) {
                var event = EventModel.fromPtx(ptx);
                if (Constants.CITY_NAMES.containsValue(event.city)) {
                  ptxRawEventList.add(event);
                  if (checkedList.containsKey(event.srcId)) {
                    if (checkedList[event.srcId]!
                        .isBefore(event.srcUpdateTime)) {
                      checkedList[event.srcId] = event.srcUpdateTime;
                    }
                  } else {
                    checkedList[event.srcId] = event.srcUpdateTime;
                  }
                }
              });
              _ptxSeverEventList.clear();
              ptxRawEventList.forEach((event) {
                if (checkedList[event.srcId]!
                    .isAtSameMomentAs(event.srcUpdateTime)) {
                  _ptxSeverEventList.add(event);
                }
              });
              checkedList.clear();
              ptxRawEventList.clear();
              print('Number of PTX sever events: ${_ptxSeverEventList.length}');
              // Update database
              updateDatabase().then((activeIdList) {
                _setProgressDialogState(() => _progress = 0.5);
                // Remove old events from database
                deleteOldEventsFromDatabase(activeIdList).then((_) {
                  _setProgressDialogState(() => _progress = 0.75);
                  // Load events from database again
                  getEventsFromDatabase().then((_) {
                    print(
                        'Number of PTX local events: ${_ptxLocalEventList.length}');
                    _setProgressDialogState(() => _progress = 1.0);
                    _counterList.clear();
                    _ptxLocalEventList.forEach((event) {
                      if (event.endTime.isAfter(DateTime.now().toUtc())) {
                        int count = _counterList[event.city] ?? 0;
                        _counterList[event.city] = count + 1;
                      }
                    });
                    PreferenceHelper.setPtxLastModifiedTime(
                        _ptxLastModifiedTime);
                    setState(() => Navigator.pop(context));
                  });
                });
              });
            } else if (response.statusCode ==
                Constants.PTX_STATUS_CODE_IS_UP_TO_DATE) {
              // Load events from database again
              getEventsFromDatabase().then((_) {
                print(
                    'Number of PTX local events: ${_ptxLocalEventList.length}');
                _counterList.clear();
                _ptxLocalEventList.forEach((event) {
                  if (event.endTime.isAfter(DateTime.now().toUtc())) {
                    int count = _counterList[event.city] ?? 0;
                    _counterList[event.city] = count + 1;
                  }
                });
                Navigator.pop(context);
                setState(() => _alertStatus = AlertStatus.NONE);
              });
            } else {
              // Failed to get PTX data due to unknown error
              Navigator.pop(context);
              setState(() => _alertStatus = AlertStatus.SEVER_ERROR);
            }
          });
        });
      } else {
        Navigator.pop(context);
        setState(() => _alertStatus = AlertStatus.IS_OFFLINE);
      }
    });
  }

  Future<void> getEventsFromDatabase() async {
    _ptxLocalEventList.clear();
    _ptxLocalEventList =
        await DatabaseHelper.dh.getAllEvents(Constants.SOURCE_PTX);
  }

  Future<List<String>> updateDatabase() async {
    var activeIdList = <String>[];
    var counter = 0;
    for (var ptxSeverEvent in _ptxSeverEventList) {
      activeIdList.add(ptxSeverEvent.srcId);
      bool foundMatching = false;
      for (var ptxLocalEvent in _ptxLocalEventList) {
        if (ptxSeverEvent.srcId == ptxLocalEvent.srcId) {
          foundMatching = true;
          await DatabaseHelper.dh.updateEvent(ptxSeverEvent);
          break;
        }
      }
      if (!foundMatching) {
        await DatabaseHelper.dh.insertEvent(ptxSeverEvent);
      }
      _setProgressDialogState(
          () => _progress = counter * 0.5 / _ptxSeverEventList.length);
      counter++;
    }
    return activeIdList;
  }

  Future<void> deleteOldEventsFromDatabase(List<String> activeIdList) async {
    for (var ptxLocalEvent in _ptxLocalEventList) {
      if (!activeIdList.contains(ptxLocalEvent.srcId)) {
        DatabaseHelper.dh
            .deleteEvent(ptxLocalEvent.srcType, ptxLocalEvent.srcId);
      }
    }
  }

  Stack buildCityButton(String displayName, String urlName) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(
            left: 10 * _scale, right: 10 * _scale, top: 3 * _scale),
        child: OutlinedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(
                left: 14 * _scale,
                right: 14 * _scale,
                top: 3 * _scale,
                bottom: 5 * _scale)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            side: MaterialStateProperty.all<BorderSide>(
                BorderSide(color: Constants.COLOR_THEME_WHITE, width: 1)),
            backgroundColor: MaterialStateProperty.all<Color>(
                Constants.COLOR_THEME_TRANSPARENT_BLACK),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(currentCity: urlName)));
          },
          child: Row(
            children: [
              Text(
                displayName,
                // '$displayName (${_counterList[displayName] ??= 0})',
                style:
                    TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      Visibility(
        visible: _counterList[displayName] != null,
        child: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.symmetric(
              vertical: 3 * _scale, horizontal: 5 * _scale),
          decoration: BoxDecoration(
            color: Constants.COLOR_THEME_RED,
            border: Border.all(color: Constants.COLOR_THEME_WHITE, width: 1),
            borderRadius: BorderRadius.all(
                Radius.circular(10) //         <--- border radius here
                ),
          ), //       <--- BoxDecoration here
          child: Text(
            '${_counterList[displayName]}',
            style: TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 12),
          ),
        ),
      ),
    ]);
  }
}
