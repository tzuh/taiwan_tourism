import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:taiwantourism/model/location_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'helper/database_helper.dart';
import 'model/event_model.dart';
import 'model/forecast_model.dart';

class EventPage extends StatefulWidget {
  final EventModel event;
  final Directory tempDir;

  final List<LocationModel> locationModelList;
  final List<ForecastModel> forecastModelList;

  EventPage(
      {required this.event,
      required this.tempDir,
      required this.locationModelList,
      required this.forecastModelList});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  ForecastModel? _firstForecast;
  ForecastModel? _secondForecast;

  @override
  void initState() {
    super.initState();
    prepareForecasts();
    widget.event.status = Constants.EVENT_STATUS_NONE;
    DatabaseHelper.dh.updateEvent(widget.event, widget.event, widget.tempDir);
  }

  @override
  Widget build(BuildContext context) {
    bool _hasAddress = widget.event.address.isNotEmpty;
    bool _hasPhone = widget.event.phone.isNotEmpty;
    bool _hasWebsite = widget.event.websiteUrl.isNotEmpty;
    bool hasImage1 = widget.event.picture.ptxPictureList.length >= 1 &&
        widget.event.picture.ptxPictureList[0].url.isNotEmpty;
    bool hasImage2 = widget.event.picture.ptxPictureList.length >= 2 &&
        widget.event.picture.ptxPictureList[1].url.isNotEmpty;
    bool hasImage3 = widget.event.picture.ptxPictureList.length >= 3 &&
        widget.event.picture.ptxPictureList[2].url.isNotEmpty;
    return Scaffold(
        backgroundColor: Constants.COLOR_THEME_DARK_WHITE,
        appBar: AppBar(
          elevation: 0,
          actions: <Widget>[],
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
          title: Text(
            Constants.STRING_EVENT,
            style: TextStyle(fontSize: 20, color: Constants.COLOR_THEME_WHITE),
            textAlign: TextAlign.center,
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: double.infinity,
            margin:
                EdgeInsets.symmetric(vertical: Constants.DIMEN_PRIMARY_MARGIN),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                        vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                    child: SelectableText(
                      '${widget.event.name}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Constants.COLOR_THEME_BLACK,
                      ),
                      textAlign: TextAlign.center,
                    )),
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                        vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                    child: SelectableText(
                      getEventDateString(
                          widget.event.startTime, widget.event.endTime),
                      style: TextStyle(
                          fontSize: 16,
                          color: widget.event.endTime
                                  .isBefore(DateTime.now().toUtc())
                              ? Constants.COLOR_THEME_RED
                              : Constants.COLOR_THEME_BLACK),
                      textAlign: TextAlign.center,
                    )),
                Visibility(
                    visible: _hasAddress,
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                        child: SelectableText(
                          '${widget.event.address}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Constants.COLOR_THEME_BLACK,
                          ),
                          textAlign: TextAlign.center,
                        ))),
                Visibility(
                    visible: _hasPhone,
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                        child: SelectableText(
                          '${getPhoneNumberString(widget.event.phone)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Constants.COLOR_THEME_BLACK,
                          ),
                          textAlign: TextAlign.center,
                        ))),
                Visibility(
                    visible: _hasAddress || _hasWebsite || _hasPhone,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                              visible: _hasAddress,
                              child: IconButton(
                                padding: EdgeInsets.all(
                                    Constants.DIMEN_ICON_BUTTON / 6),
                                alignment: Alignment.center,
                                iconSize: Constants.DIMEN_ICON_BUTTON,
                                onPressed: () async {
                                  String address = widget.event.address;
                                  String city = Constants.CITY_ID_TO_STRING[
                                          widget.event.cityId] ??
                                      '';
                                  if (!address.startsWith(city)) {
                                    address = '$city ' + address;
                                  }
                                  String query = Uri.encodeComponent(address);
                                  String url =
                                      'https://www.google.com/maps/search/?api=1&query=$query';
                                  if (await launch(url)) {
                                    throw 'Could not launch $url';
                                  }
                                },
                                icon: Icon(
                                  Icons.map_outlined,
                                  color: Constants.COLOR_THEME_BLUE_GREY,
                                  size: Constants.DIMEN_ICON_BUTTON,
                                ),
                              )),
                          Visibility(
                              visible: _hasWebsite,
                              child: IconButton(
                                padding: EdgeInsets.all(
                                    Constants.DIMEN_ICON_BUTTON / 6),
                                alignment: Alignment.center,
                                iconSize: Constants.DIMEN_ICON_BUTTON,
                                onPressed: () async {
                                  if (await launch(widget.event.websiteUrl)) {
                                    throw 'Could not launch ${widget.event.websiteUrl}';
                                  }
                                },
                                icon: Icon(
                                  Icons.web,
                                  color: Constants.COLOR_THEME_BLUE_GREY,
                                  size: Constants.DIMEN_ICON_BUTTON,
                                ),
                              )),
                          Visibility(
                              visible: _hasPhone,
                              child: IconButton(
                                padding: EdgeInsets.all(
                                    Constants.DIMEN_ICON_BUTTON / 6),
                                alignment: Alignment.center,
                                iconSize: Constants.DIMEN_ICON_BUTTON,
                                onPressed: () async {
                                  String phoneNum =
                                      getPhoneNumberString(widget.event.phone)
                                          .replaceAll('-', '');
                                  if (await launch('tel:' + phoneNum)) {
                                    throw 'Could not launch $phoneNum';
                                  }
                                },
                                icon: Icon(
                                  Icons.phone,
                                  color: Constants.COLOR_THEME_BLUE_GREY,
                                  size: Constants.DIMEN_ICON_BUTTON,
                                ),
                              )),
                        ],
                      ),
                    )),
                Visibility(
                  visible: _firstForecast != null && _secondForecast != null,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                        vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                    alignment: Alignment.center,
                    color: Constants.COLOR_TRANSPARENT,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Constants.COLOR_THEME_BLUE_GREY,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8)),
                            ),
                            child: Text(
                              _firstForecast == null
                                  ? ''
                                  : (_firstForecast!.locationName + ' 天氣預報'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Constants.COLOR_THEME_WHITE,
                              ),
                              textAlign: TextAlign.center,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                      top: Constants.DIMEN_PRIMARY_MARGIN / 4,
                                      bottom:
                                          Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      right: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                    ),
                                    color: Constants.COLOR_THEME_WHITE,
                                    child: Text(
                                        getForecastDateString(_firstForecast),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Constants.COLOR_THEME_BLACK,
                                        ),
                                        textAlign: TextAlign.center),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                      top: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      bottom:
                                          Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      right: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Constants.COLOR_THEME_WHITE,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8)),
                                    ),
                                    child: Text(
                                        getForecastContentString(
                                            _firstForecast),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Constants.COLOR_THEME_BLACK,
                                        ),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                      top: Constants.DIMEN_PRIMARY_MARGIN / 4,
                                      bottom:
                                          Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      left: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                    ),
                                    color: Constants.COLOR_THEME_WHITE,
                                    child: Text(
                                        getForecastDateString(_secondForecast),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Constants.COLOR_THEME_BLACK,
                                        ),
                                        textAlign: TextAlign.center),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                      top: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      bottom:
                                          Constants.DIMEN_PRIMARY_MARGIN / 8,
                                      left: Constants.DIMEN_PRIMARY_MARGIN / 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Constants.COLOR_THEME_WHITE,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8)),
                                    ),
                                    child: Text(
                                        getForecastContentString(
                                            _secondForecast),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Constants.COLOR_THEME_BLACK,
                                        ),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: widget.event.organizer.isNotEmpty,
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                        child: SelectableText(
                          '${Constants.STRING_ORGANIZER}${widget.event.organizer}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Constants.COLOR_THEME_BLACK,
                          ),
                          textAlign: TextAlign.center,
                        ))),
                Visibility(
                    visible: hasImage1,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                          vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                      decoration: BoxDecoration(
                          color: Constants.COLOR_THEME_WHITE,
                          border: Border.all(
                            color: Constants.COLOR_THEME_WHITE,
                            width: Constants.DIMEN_PRIMARY_MARGIN,
                          )),
                      child: Column(
                        children: [
                          Image(
                            image: NetworkToFileImage(
                              url: hasImage1
                                  ? widget.event.picture.ptxPictureList[0].url
                                  : '',
                              file: File(path.join(widget.tempDir.path,
                                  '${widget.event.srcType}_${widget.event.srcId}_1.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                hasImage1
                                    ? '${widget.event.picture.ptxPictureList[0].description}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Constants.COLOR_THEME_BLACK,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 6,
                              ))
                        ],
                      ),
                    )),
                Visibility(
                    visible: hasImage2,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                          vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                      decoration: BoxDecoration(
                          color: Constants.COLOR_THEME_WHITE,
                          border: Border.all(
                            color: Constants.COLOR_THEME_WHITE,
                            width: Constants.DIMEN_PRIMARY_MARGIN,
                          )),
                      child: Column(
                        children: [
                          Image(
                            image: NetworkToFileImage(
                              url: hasImage2
                                  ? widget.event.picture.ptxPictureList[1].url
                                  : '',
                              file: File(path.join(widget.tempDir.path,
                                  '${widget.event.srcType}_${widget.event.srcId}_2.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                hasImage2
                                    ? '${widget.event.picture.ptxPictureList[1].description}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Constants.COLOR_THEME_BLACK,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 6,
                              ))
                        ],
                      ),
                    )),
                Visibility(
                    visible: hasImage3,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                          vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                      decoration: BoxDecoration(
                          color: Constants.COLOR_THEME_WHITE,
                          border: Border.all(
                            color: Constants.COLOR_THEME_WHITE,
                            width: Constants.DIMEN_PRIMARY_MARGIN,
                          )),
                      child: Column(
                        children: [
                          Image(
                            image: NetworkToFileImage(
                              url: hasImage3
                                  ? widget.event.picture.ptxPictureList[2].url
                                  : '',
                              file: File(path.join(widget.tempDir.path,
                                  '${widget.event.srcType}_${widget.event.srcId}_3.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                hasImage3
                                    ? '${widget.event.picture.ptxPictureList[2].description}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Constants.COLOR_THEME_BLACK,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 6,
                              ))
                        ],
                      ),
                    )),
                Visibility(
                    visible: widget.event.description.isNotEmpty,
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                        child: SelectableText(
                          '${widget.event.description}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Constants.COLOR_THEME_BLACK,
                          ),
                        ))),
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                        vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                    child: Text(
                      '${Constants.STRING_UPDATE_TIME}${DateFormat('yyyy/M/d').format(widget.event.originalUpdateTime.toLocal())}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Constants.COLOR_THEME_BLACK,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ));
  }

  void prepareForecasts() {
    if (widget.locationModelList.length > 0 &&
        widget.forecastModelList.length > 0) {
      final EventModel event = widget.event;
      // Find current location
      String currentLocationName = widget.locationModelList[0].name;
      double shortestDis = double.maxFinite;
      for (int i = 0; i < widget.locationModelList.length; i++) {
        final LocationModel model = widget.locationModelList[i];
        bool foundKeyword = model.name.isNotEmpty &&
            ((event.address.isNotEmpty && event.address.contains(model.name)) ||
                (event.location.isNotEmpty &&
                    event.location.contains(model.name)));
        bool foundPositions = event.position.positionLat != 0 &&
            event.position.positionLon != 0 &&
            model.positionLat != ForecastModel.FLOAT_NONE &&
            model.positionLon != ForecastModel.FLOAT_NONE;
        if (foundKeyword) {
          currentLocationName = model.name;
          break;
        } else if (foundPositions) {
          final x = (model.positionLat - event.position.positionLat).abs();
          final y = (model.positionLon - event.position.positionLon).abs();
          final dis = sqrt(x * x + y * y);
          if (dis < shortestDis) {
            shortestDis = dis;
            currentLocationName = model.name;
          }
        }
      }
      // Find the timestamp
      DateTime? firstForecastEndTime; // UTC time
      final hourOfDayStart = 6;
      final hourOfNightStart = 18;
      DateTime twNow = DateTime.now().toUtc().add(Duration(hours: 8));
      DateTime twEventStartTime = event.startTime.add(Duration(hours: 8));
      DateTime twEventEndTime = event.endTime.add(Duration(hours: 8));
      if (twNow.isBefore(twEventStartTime)) {
        firstForecastEndTime = DateTime.utc(twEventStartTime.year,
                twEventStartTime.month, twEventStartTime.day, hourOfDayStart)
            .add(Duration(hours: 12))
            .subtract(Duration(hours: 8));
      } else if (twNow.isBefore(twEventEndTime)) {
        if (twNow.hour < hourOfDayStart) {
          firstForecastEndTime =
              DateTime.utc(twNow.year, twNow.month, twNow.day, hourOfDayStart)
                  .subtract(Duration(hours: 8));
        } else if (twNow.hour < hourOfNightStart) {
          firstForecastEndTime =
              DateTime.utc(twNow.year, twNow.month, twNow.day, hourOfNightStart)
                  .subtract(Duration(hours: 8));
        } else {
          firstForecastEndTime =
              DateTime.utc(twNow.year, twNow.month, twNow.day, hourOfNightStart)
                  .add(Duration(hours: 12))
                  .subtract(Duration(hours: 8));
        }
      }
      // Get forecasts
      if (firstForecastEndTime != null) {
        for (int tryNext = 0; tryNext < 2; tryNext++) {
          if (_firstForecast == null) {
            for (int i = 0; i < widget.forecastModelList.length; i++) {
              final ForecastModel model = widget.forecastModelList[i];
              if (currentLocationName == model.locationName) {
                if (_firstForecast == null) {
                  if (model.endTime.isAtSameMomentAs(firstForecastEndTime!)) {
                    _firstForecast = model;
                  }
                } else if (_secondForecast == null) {
                  if (model.endTime.isAtSameMomentAs(
                      firstForecastEndTime!.add(Duration(hours: 12)))) {
                    _secondForecast = model;
                    break;
                  }
                }
              }
            }
          }
          firstForecastEndTime = firstForecastEndTime!.add(Duration(hours: 12));
        }
      }
    }
  }

  String getPhoneNumberString(String phoneNum) {
    if (phoneNum.startsWith('+886-')) {
      phoneNum = phoneNum.substring(5);
      return '0' + phoneNum;
    } else if (phoneNum.startsWith('+') || phoneNum.startsWith('0')) {
      return phoneNum;
    } else {
      return '0' + phoneNum;
    }
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
        return '${DateFormat('yyyy/M/d HH:mm').format(localStartDateTime)} - ${DateFormat('HH:mm').format(localEndDateTime)}';
      } else {
        // 多日活動
        return '${DateFormat('yyyy/M/d HH:mm').format(localStartDateTime)} - ${DateFormat('yyyy/M/d HH:mm').format(localEndDateTime)}';
      }
    }
  }

  String getForecastDateString(ForecastModel? forecast) {
    String outputString = '';
    if (forecast != null) {
      final hourOfDayStart = 6;
      DateTime twNow = DateTime.now().toUtc().add(Duration(hours: 8));
      DateTime twForecastStartTime = forecast.endTime
          .subtract(Duration(hours: 12))
          .add(Duration(hours: 8));
      if (twNow.year == twForecastStartTime.year &&
          twNow.month == twForecastStartTime.month &&
          twNow.day == twForecastStartTime.day) {
        outputString += '今日';
      } else {
        outputString += twForecastStartTime.month.toString() +
            '/' +
            twForecastStartTime.day.toString() +
            ' ';
      }
      if (twForecastStartTime.hour == hourOfDayStart) {
        outputString += '白天';
      } else {
        outputString += '晚上';
      }
    }
    return outputString;
  }

  String getForecastContentString(ForecastModel? forecast) {
    String outputString = '';
    if (forecast != null) {
      if (forecast.minT == forecast.maxT) {
        outputString += forecast.minT.toString();
      } else {
        outputString +=
            forecast.minT.toString() + '~' + forecast.maxT.toString();
      }
      outputString += '°C\n' +
          forecast.wx +
          (forecast.pOP == ForecastModel.INT_NONE
              ? ''
              : ('\n' + forecast.pOP.toString() + '% '));
    }
    return outputString;
  }
}
