import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'helper/database_helper.dart';
import 'model/event_model.dart';

class EventPage extends StatefulWidget {
  final EventModel event;
  final Directory tempDir;

  EventPage({required this.event, required this.tempDir});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  void initState() {
    super.initState();
    widget.event.status = Constants.EVENT_STATUS_NONE;
    DatabaseHelper.dh.updateEvent(widget.event,widget.event, widget.tempDir);
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
                          '${widget.event.phone}',
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
                                  if (!address
                                      .startsWith(widget.event.cityId)) {
                                    address =
                                        '${widget.event.cityId} ' + address;
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
                                  if (await launch(
                                      'tel:' + widget.event.phone)) {
                                    throw 'Could not launch ${widget.event.phone}';
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
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.srcId}_${widget.event.srcType}1.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
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
                                textAlign: TextAlign.center,
                                maxLines: 2,
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
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.srcId}_${widget.event.srcType}2.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
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
                                textAlign: TextAlign.center,
                                maxLines: 2,
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
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.srcId}_${widget.event.srcType}3.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
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
                                textAlign: TextAlign.center,
                                maxLines: 2,
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
}
