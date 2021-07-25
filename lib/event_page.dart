import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'model/activity_tourism_info.dart';

class EventPage extends StatefulWidget {
  final ActivityTourismInfo event;
  final Directory tempDir;

  EventPage({required this.event, required this.tempDir});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    bool _hasAddress = widget.event.address.isNotEmpty;
    bool _hasPhone = widget.event.phone.isNotEmpty;
    bool _hasWebsite = widget.event.websiteUrl.isNotEmpty;
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
            Constants.STRING_ACTIVITY,
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
                      getDateString(
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
                    visible: _hasPhone || _hasWebsite,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                              visible: _hasWebsite,
                              child: IconButton(
                                onPressed: () async {
                                  await canLaunch(widget.event.websiteUrl)
                                      ? await launch(widget.event.websiteUrl)
                                      : throw 'Could not launch ${widget.event.websiteUrl}';
                                },
                                icon: Icon(
                                  Icons.web,
                                  color: Constants.COLOR_THEME_BLUE_GREY,
                                  size: 30.0,
                                ),
                              )),
                          Visibility(
                              visible: _hasPhone,
                              child: IconButton(
                                onPressed: () async {
                                  await canLaunch(
                                          'tel:' + widget.event.phone)
                                      ? await launch(
                                          'tel:' + widget.event.phone)
                                      : throw 'Could not launch ${widget.event.phone}';
                                },
                                icon: Icon(
                                  Icons.phone,
                                  color: Constants.COLOR_THEME_BLUE_GREY,
                                  size: 30.0,
                                ),
                              )),
                        ],
                      ),
                    )),
                Visibility(
                    visible: widget.event.picture.pictureUrl1.isNotEmpty,
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
                              url: widget.event.picture.pictureUrl1,
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.id}_a1.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.event.picture.pictureDescription1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Constants.COLOR_THEME_BLACK,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ))
                        ],
                      ),
                    )),
                Visibility(
                    visible: widget.event.picture.pictureUrl2.isNotEmpty,
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
                              url: widget.event.picture.pictureUrl2,
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.id}_a2.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.event.picture.pictureDescription2}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Constants.COLOR_THEME_BLACK,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ))
                        ],
                      ),
                    )),
                Visibility(
                    visible: widget.event.picture.pictureUrl3.isNotEmpty,
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
                              url: widget.event.picture.pictureUrl3,
                              file: File(join(widget.tempDir.path,
                                  '${widget.event.id}_a3.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.event.picture.pictureDescription3}',
                                style: TextStyle(
                                  fontSize: 12,
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
              ],
            ),
          ),
        ));
  }

  String getDateString(DateTime startDate, DateTime endDate) {
    DateTime localStartDate = startDate.toLocal();
    DateTime localEndDate = endDate.toLocal();
    if (localStartDate.isAtSameMomentAs(localEndDate)) {
      return '${localStartDate.year}/${localStartDate.month}/${localStartDate.day}';
    } else {
      return '${localStartDate.year}/${localStartDate.month}/${localStartDate.day} - ${localEndDate.year}/${localEndDate.month}/${localEndDate.day}';
    }
  }
}
