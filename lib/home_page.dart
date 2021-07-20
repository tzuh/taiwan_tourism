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
import 'package:taiwantourism/activity_page.dart';
import 'package:taiwantourism/model/activity_tourism_info.dart';
import 'package:taiwantourism/setting_page.dart';
import 'package:taiwantourism/util/network_util.dart';
import 'constants.dart';
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
  List<ActivityTourismInfo> _activityList = <ActivityTourismInfo>[];
  var _alertStatus = AlertStatus.NONE;

  @override
  void initState() {
    super.initState();
    initVariables().then((value) {
      NetworkUtil.isAvailable().then((isAvailable) {
        if (isAvailable) {
          refreshDataByCity(widget.currentCity);
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
                  MaterialPageRoute(builder: (context) => SettingPage()));
            },
          )
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(
              vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
          itemCount: _activityList.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityPage(
                                activity: _activityList[index],
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
                      image: _activityList[index].picture.pictureUrl1.isNotEmpty
                          ? NetworkToFileImage(
                              url: _activityList[index].picture.pictureUrl1,
                              file: File(join(_tempDir.path,
                                  '${_activityList[index].id}_a1.jpg')),
                              debug: false,
                            )
                          : Image.asset('assets/images/card_bg.jpg').image,
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
                              '${_activityList[index].name}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  backgroundColor: Colors.transparent),
                              maxLines: 2,
                            ),
                            Text(
                              _activityList[index].location,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  backgroundColor: Colors.transparent),
                              maxLines: 1,
                            ),
                            Text(
                              getDateString(_activityList[index].startTime,
                                  _activityList[index].endTime),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: _activityList[index]
                                          .endTime
                                          .isBefore(DateTime.now().toUtc())
                                      ? Constants.COLOR_THEME_RED
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ));
          }),
    );
  }

  Future<void> initVariables() async {
    _tempDir = await getTemporaryDirectory();
  }

  void refreshDataByCity(String city) {
    getPtxDataByCity(city).then((response) {
      print('PTX status code: ${response.statusCode}');
      if (response.statusCode == Constants.HTTP_STATUS_CODE_OK) {
        _activityList.clear();
        List<PtxActivityTourismInfo> list = List<PtxActivityTourismInfo>.from(
            json
                .decode(response.body)
                .map((s) => PtxActivityTourismInfo.fromJson(s)));
        List<ActivityTourismInfo> rawActivityList = <ActivityTourismInfo>[];
        var checkedList = Map<String, DateTime>();
        list.forEach((ptx) {
          var activity = ActivityTourismInfo.fromPtx(ptx);
          rawActivityList.add(activity);
          if (checkedList.containsKey(activity.id)) {
            if (checkedList[activity.id]!.isBefore(activity.updateTime)) {
              checkedList[activity.id] = activity.updateTime;
            }
          } else {
            checkedList[activity.id] = activity.updateTime;
          }
        });
        List<ActivityTourismInfo> oldActivityList = <ActivityTourismInfo>[];
        List<ActivityTourismInfo> newActivityList = <ActivityTourismInfo>[];
        DateTime now = DateTime.now().toUtc();
        rawActivityList.forEach((activity) {
          if (checkedList[activity.id]!.isAtSameMomentAs(activity.updateTime)) {
            if (activity.endTime.isBefore(now)) {
              oldActivityList.add(activity);
            } else {
              newActivityList.add(activity);
            }
          }
        });
        rawActivityList.clear();
        oldActivityList.sort((a, b) => a.endTime.isBefore(b.endTime) ? 1 : -1);
        newActivityList.sort((a, b) => a.endTime.isAfter(b.endTime) ? 1 : -1);
        _activityList = newActivityList + oldActivityList;
      } else {
        // Failed to get PTX data due to unknown error
        _alertStatus = AlertStatus.SEVER_ERROR;
      }
      setState(() {});
    });
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
        DateFormat('EEE, d MMM y HH:mm:ss').format(DateTime.now().toUtc());
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
