import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'model/activity_tourism_info.dart';

class ActivityPage extends StatefulWidget {
  final ActivityTourismInfo activity;
  final Directory tempDir;

  ActivityPage({required this.activity, required this.tempDir});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    bool _hasAddress = widget.activity.address.isNotEmpty;
    bool _hasPhone = widget.activity.phone.isNotEmpty;
    bool _hasWebsite = widget.activity.websiteUrl.isNotEmpty;
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
                      '${widget.activity.name}',
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
                          widget.activity.startTime, widget.activity.endTime),
                      style: TextStyle(
                          fontSize: 16,
                          color: widget.activity.endTime
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
                          '${widget.activity.address}',
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
                          '${widget.activity.phone}',
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
                                  await canLaunch(widget.activity.websiteUrl)
                                      ? await launch(widget.activity.websiteUrl)
                                      : throw 'Could not launch ${widget.activity.websiteUrl}';
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
                                          'tel:' + widget.activity.phone)
                                      ? await launch(
                                          'tel:' + widget.activity.phone)
                                      : throw 'Could not launch ${widget.activity.phone}';
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
                    visible: widget.activity.picture.pictureUrl1.isNotEmpty,
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
                              url: widget.activity.picture.pictureUrl1,
                              file: File(join(widget.tempDir.path,
                                  '${widget.activity.id}_a1.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.activity.picture.pictureDescription1}',
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
                    visible: widget.activity.picture.pictureUrl2.isNotEmpty,
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
                              url: widget.activity.picture.pictureUrl2,
                              file: File(join(widget.tempDir.path,
                                  '${widget.activity.id}_a2.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.activity.picture.pictureDescription2}',
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
                    visible: widget.activity.picture.pictureUrl3.isNotEmpty,
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
                              url: widget.activity.picture.pictureUrl3,
                              file: File(join(widget.tempDir.path,
                                  '${widget.activity.id}_a3.jpg')),
                              debug: false,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top: Constants.DIMEN_PRIMARY_MARGIN / 2),
                              child: Text(
                                '${widget.activity.picture.pictureDescription3}',
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
                    visible: widget.activity.description.isNotEmpty,
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
                            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
                        child: SelectableText(
                          '${widget.activity.description}',
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
