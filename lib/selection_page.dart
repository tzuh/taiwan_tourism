import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taiwantourism/helper/preference_helper.dart';
import 'package:taiwantourism/util/network_util.dart';
import 'constants.dart';
import 'helper/database_helper.dart';
import 'helper/tdx_helper.dart';
import 'home_page.dart';
import 'model/event_model.dart';
import 'model/tdx/tdx_activity_tourism_info.dart';
import 'model/tdx/tdx_token_info.dart';

enum AlertStatus {
  NONE,
  LOCK,
  IS_OFFLINE,
  SEVER_ERROR,
}

class SelectionPage extends StatefulWidget {
  SelectionPage();

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late Directory _tempDir;
  var _autoRetry = true;
  var _selectedCity = '';
  var _tdxLocalEventList = <EventModel>[];
  var _tdxSeverEventList = <EventModel>[];
  var _cityCountList = Map<String, int>();
  var _cityHighlightList = <String>[];
  var _alertStatus = AlertStatus.NONE;
  var _lastPressedBackButton = DateTime.now()
      .toUtc()
      .add(Duration(seconds: -Constants.SECONDS_FOR_QUIT));
  double _layoutScale = 1.0;
  StateSetter? _setProgressDialogState;
  double _progress = -1.0;
  String _progressMessage = Constants.STRING_CHECKING_DATA;
  String _tdxLastModifiedTime = '';

  @override
  void initState() {
    super.initState();
    initVariables().then((_) {
      setState(() => _alertStatus = AlertStatus.LOCK);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final _screenDiagonal = sqrt(pow(_screenHeight, 2) + pow(screenWidth, 2));
    _layoutScale = _screenDiagonal / 900;

    Future.delayed(Duration.zero, () {
      switch (_alertStatus) {
        case AlertStatus.LOCK:
          showProgressDialog(context);
          prepareData();
          break;
        case AlertStatus.IS_OFFLINE:
          showAlertDialog(context, Constants.STRING_OFFLINE,
              Constants.STRING_CHECK_CONNECTION);
          break;
        case AlertStatus.SEVER_ERROR:
          showAlertDialog(context, Constants.STRING_SEVER_ERROR,
              Constants.STRING_TRY_LATER);
          _autoRetry = false;
          break;
        default:
          break;
      }
      _alertStatus = AlertStatus.NONE;
    });

    return WillPopScope(
      onWillPop: () async {
        var now = DateTime.now().toUtc();
        if (now.difference(_lastPressedBackButton).inSeconds >
            Constants.SECONDS_FOR_QUIT) {
          _lastPressedBackButton = now;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(Constants.STRING_PRESS_AGAIN_TO_QUIT),
            backgroundColor: Constants.COLOR_THEME_TRANSPARENT_BLACK,
          ));
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.COLOR_THEME_BLUE_GREY,
        body: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: _screenHeight / 30),
          decoration: BoxDecoration(
            color: Constants.COLOR_THEME_BLUE_GREY,
            image: DecorationImage(
              image: AssetImage('assets/images/selection_bg.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildCityButton(Constants.TAOYUAN),
                    buildCityButton(Constants.HSINCHU),
                    buildCityButton(Constants.HSINCHU_COUNTY),
                    buildCityButton(Constants.MIAOLI_COUNTY),
                    buildCityButton(Constants.TAICHUNG),
                    buildCityButton(Constants.CHANGHUA_COUNTY),
                    buildCityButton(Constants.YUNLIN_COUNTY),
                    buildCityButton(Constants.CHIAYI),
                    buildCityButton(Constants.CHIAYI_COUNTY),
                    buildCityButton(Constants.TAINAN),
                    buildCityButton(Constants.KAOHSIUNG),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildCityButton(Constants.KEELUNG),
                    buildCityButton(Constants.TAIPEI),
                    buildCityButton(Constants.NEW_TAIPEI),
                    buildCityButton(Constants.YILAN_COUNTY),
                    buildCityButton(Constants.HUALIEN_COUNTY),
                    buildCityButton(Constants.NANTOU_COUNTY),
                    buildCityButton(Constants.TAITUNG_COUNTY),
                    buildCityButton(Constants.PINGTUNG_COUNTY),
                    buildCityButton(Constants.LIENCHIANG_COUNTY),
                    buildCityButton(Constants.KINMEN_COUNTY),
                    buildCityButton(Constants.PENGHU_COUNTY),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initVariables() async {
    _tempDir = await getTemporaryDirectory();
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
      backgroundColor: Constants.COLOR_THEME_DARK_WHITE,
      actions: [
        TextButton(
          child: Text(Constants.STRING_CANCEL),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(Constants.STRING_RETRY),
          onPressed: () {
            Navigator.pop(context);
            setState(() => _alertStatus = AlertStatus.LOCK);
          },
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
        getEventsFromDatabase().then((_) {
          print('Number of TDX local events: ${_tdxLocalEventList.length}');
          TdxHelper.getTdxEvents(300).then((response) {
            print('TDX status code: ${response.statusCode}');
            if (response.statusCode == Constants.HTTP_STATUS_CODE_OK) {
              _tdxLastModifiedTime = response
                      .headers[Constants.TDX_RESPONSE_HEADER_LAST_MODIFIED] ??
                  '';
              _progressMessage = Constants.STRING_UPDATING_DATA;
              if (_setProgressDialogState != null) {
                _setProgressDialogState!(() => _progress = 0.0);
              }
              // Parse data
              List<TdxActivityTourismInfo> list =
                  List<TdxActivityTourismInfo>.from(json
                      .decode(response.body)
                      .map((s) => TdxActivityTourismInfo.fromJson(s)));
              // Prepare sever data and remove useless data
              List<EventModel> tdxRawEventList = <EventModel>[];
              var checkedList = Map<String, DateTime>();
              list.forEach((tdx) {
                var event = EventModel.fromTdx(tdx);
                if (event.cityId.isNotEmpty) {
                  tdxRawEventList.add(event);
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
              _tdxSeverEventList.clear();
              tdxRawEventList.forEach((event) {
                if (checkedList[event.srcId]!
                    .isAtSameMomentAs(event.srcUpdateTime)) {
                  _tdxSeverEventList.add(event);
                }
              });
              checkedList.clear();
              tdxRawEventList.clear();
              print('Number of TDX sever events: ${_tdxSeverEventList.length}');
              // Update database
              updateDatabase().then((activeIdList) {
                if (_setProgressDialogState != null) {
                  _setProgressDialogState!(() => _progress = 0.5);
                }
                // Remove old events from database
                deleteOldEventsFromDatabase(activeIdList).then((_) {
                  if (_setProgressDialogState != null) {
                    _setProgressDialogState!(() => _progress = 0.75);
                  }
                  // Load events from database again
                  getEventsFromDatabase().then((_) {
                    print(
                        'Number of TDX local events: ${_tdxLocalEventList.length}');
                    if (_setProgressDialogState != null) {
                      _setProgressDialogState!(() => _progress = 1.0);
                    }
                    PreferenceHelper.setTdxLastModifiedTime(
                        _tdxLastModifiedTime);
                    _autoRetry = false;
                    prepareCityLabels();
                    Navigator.pop(context);
                    setState(() {});
                  });
                });
              });
            } else if (response.statusCode ==
                Constants.TDX_STATUS_CODE_IS_UP_TO_DATE) {
              // Load events from database
              getEventsFromDatabase().then((_) {
                print(
                    'Number of TDX local events: ${_tdxLocalEventList.length}');
                _autoRetry = false;
                prepareCityLabels();
                Navigator.pop(context);
                setState(() {});
              });
            } else if (response.statusCode ==
                Constants.TDX_STATUS_CODE_UNAUTHORIZED) {
              print('getAccessToken');
              TdxHelper.getAccessToken().then((response) {
                print('TDX status code: ${response.statusCode}');
                if (response.statusCode == Constants.HTTP_STATUS_CODE_OK) {
                  // Parse data
                  TdxTokenInfo tokenInfo =
                      TdxTokenInfo.fromJson(jsonDecode(response.body));
                  PreferenceHelper.setTdxAccessToken(tokenInfo.accessToken!);
                  prepareData();
                } else {
                  // Load events from database
                  getEventsFromDatabase().then((_) {
                    print(
                        'Number of TDX local events: ${_tdxLocalEventList.length}');
                    _autoRetry = false;
                    prepareCityLabels();
                    Navigator.pop(context);
                    setState(() => _alertStatus = AlertStatus.SEVER_ERROR);
                  });
                }
              });
            } else {
              // Load events from database
              getEventsFromDatabase().then((_) {
                print(
                    'Number of TDX local events: ${_tdxLocalEventList.length}');
                _autoRetry = false;
                prepareCityLabels();
                Navigator.pop(context);
                setState(() => _alertStatus = AlertStatus.SEVER_ERROR);
              });
            }
          });
        });
      } else {
        // Load events from database
        getEventsFromDatabase().then((_) {
          print('Number of TDX local events: ${_tdxLocalEventList.length}');
          prepareCityLabels();
          Navigator.pop(context);
          setState(() => _alertStatus = AlertStatus.IS_OFFLINE);
        });
      }
    });
  }

  Future<void> getEventsFromDatabase() async {
    _tdxLocalEventList.clear();
    _tdxLocalEventList =
        await DatabaseHelper.dh.getAllEvents(Constants.SOURCE_TDX);
  }

  Future<List<String>> updateDatabase() async {
    var activeIdList = <String>[];
    var counter = 0;
    var utcNow = DateTime.now().toUtc();
    for (var tdxSeverEvent in _tdxSeverEventList) {
      activeIdList.add(tdxSeverEvent.srcId);
      bool foundMatching = false;
      for (var tdxLocalEvent in _tdxLocalEventList) {
        if (tdxSeverEvent.srcId == tdxLocalEvent.srcId) {
          foundMatching = true;
          if (tdxSeverEvent.srcUpdateTime
              .isAfter(tdxLocalEvent.srcUpdateTime)) {
            if (tdxSeverEvent.endTime.isAfter(utcNow)) {
              tdxSeverEvent.status = tdxLocalEvent.status;
            } else {
              tdxSeverEvent.status = Constants.EVENT_STATUS_NONE;
            }
            await DatabaseHelper.dh
                .updateEvent(tdxSeverEvent, tdxLocalEvent, _tempDir);
          } else if (tdxLocalEvent.status == Constants.EVENT_STATUS_NEW &&
              tdxLocalEvent.endTime.isBefore(utcNow)) {
            tdxLocalEvent.status = Constants.EVENT_STATUS_NONE;
            await DatabaseHelper.dh
                .updateEvent(tdxLocalEvent, tdxLocalEvent, _tempDir);
          }
          break;
        }
      }
      if (!foundMatching) {
        if (tdxSeverEvent.endTime.isAfter(utcNow) &&
            _tdxLocalEventList.length > 0) {
          tdxSeverEvent.status = Constants.EVENT_STATUS_NEW;
        }
        await DatabaseHelper.dh.insertEvent(tdxSeverEvent);
      }
      if (_setProgressDialogState != null) {
        _setProgressDialogState!(
            () => _progress = counter * 0.5 / _tdxSeverEventList.length);
      }
      counter++;
    }
    return activeIdList;
  }

  Future<void> deleteOldEventsFromDatabase(List<String> activeIdList) async {
    for (var tdxLocalEvent in _tdxLocalEventList) {
      if (!activeIdList.contains(tdxLocalEvent.srcId)) {
        DatabaseHelper.dh
            .deleteEvent(tdxLocalEvent.srcType, tdxLocalEvent.srcId, _tempDir);
      }
    }
  }

  void prepareCityLabels() {
    var utcNow = DateTime.now().toUtc();
    _cityCountList.clear();
    _cityHighlightList.clear();
    _tdxLocalEventList.forEach((event) {
      if (event.endTime.isAfter(utcNow)) {
        int count = _cityCountList[event.cityId] ?? 0;
        _cityCountList[event.cityId] = count + 1;
      }
      if (event.status == Constants.EVENT_STATUS_NEW &&
          !_cityHighlightList.contains(event.cityId)) {
        _cityHighlightList.add(event.cityId);
      }
    });
  }

  Stack buildCityButton(String cityId) {
    String cityString = Constants.CITY_ID_TO_STRING[cityId] ?? '';
    return Stack(children: [
      Container(
        padding: EdgeInsets.all(0),
        margin:
            EdgeInsets.only(left: 32 * _layoutScale, right: 32 * _layoutScale),
        child: OutlinedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(
                left: 14 * _layoutScale,
                right: 14 * _layoutScale,
                top: 5 * _layoutScale,
                bottom: 5 * _layoutScale)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            side: MaterialStateProperty.all<BorderSide>(
                BorderSide(color: Constants.COLOR_THEME_WHITE, width: 1)),
            backgroundColor: MaterialStateProperty.all<Color>(
                Constants.COLOR_THEME_TRANSPARENT_BLACK),
          ),
          onPressed: () {
            _selectedCity = cityId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  currentCity: cityId,
                  tempDir: _tempDir,
                ),
              ),
            ).then((_) {
              NetworkUtil.isAvailable().then((isOnline) {
                if (isOnline && _autoRetry) {
                  setState(() => _alertStatus = AlertStatus.LOCK);
                } else {
                  DatabaseHelper.dh
                      .getCountOfNewEventByCity(_selectedCity)
                      .then((count) {
                    if (count == 0) {
                      setState(() => _cityHighlightList.remove(_selectedCity));
                    }
                  });
                }
              });
            });
          },
          child: Row(
            children: [
              Text(
                cityString,
                style:
                    TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      Visibility(
        visible: _cityCountList[cityId] != null,
        child: Container(
          alignment: Alignment.bottomRight,
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          width: 36 * _layoutScale,
          child: Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(
                vertical: 3 * _layoutScale, horizontal: 5 * _layoutScale),
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: _cityHighlightList.contains(cityId)
                  ? Constants.COLOR_THEME_RED
                  : Constants.COLOR_THEME_LIGHT_BLACK,
              border: Border.all(color: Constants.COLOR_THEME_WHITE, width: 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8)),
            ),
            child: Text(
              '${(_cityCountList[cityId] ?? 0)}',
              style:
                  TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ]);
  }
}
