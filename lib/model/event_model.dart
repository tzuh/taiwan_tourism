import 'package:intl/intl.dart';
import 'package:taiwantourism/helper/database_helper.dart';
import 'package:taiwantourism/model/tdx/tdx_activity_tourism_info.dart';
import '../constants.dart';

class EventModel {
  int dbId = -1; // App資料庫ID
  late String srcType;
  late String srcId; // 活動訊息代碼
  late String name; // 活動名稱
  late String description; // 活動簡述
  late String participation; // 活動參與對象
  late String location; // 主要活動地點名稱
  late String address; // 主要活動地點地址
  late String phone; // 活動聯絡電話
  late String organizer; // 活動主辦單位
  late DateTime startTime; // 活動開始時間
  late DateTime endTime; // 活動結束時間
  late String cycle; // 週期性活動執行時間
  late String nonCycle; // 非週期性活動執行時間
  late String websiteUrl; // 活動網址
  late TourismPicture picture; // 活動照片
  late PointType position; // 活動位置
  late String class1; // 活動分類1
  late String class2; // 活動分類2
  late String mapUrl; // 活動地圖/簡圖連結網址
  late String travelInfo; // 交通資訊
  late String parkingInfo; // 停車資訊
  late String charge; // 費用標示
  late String remarks; // 備註(其他活動相關事項)
  late String cityId; // 所屬縣市(ID)
  late DateTime originalUpdateTime; // 觀光局檔案更新時間
  late DateTime srcUpdateTime; // 本平台資料更新時間
  int status = Constants.EVENT_STATUS_NONE;

  EventModel({
    required this.srcType,
    required this.srcId,
    required this.name,
    required this.description,
    required this.participation,
    required this.location,
    required this.address,
    required this.phone,
    required this.organizer,
    required this.startTime,
    required this.endTime,
    required this.cycle,
    required this.nonCycle,
    required this.websiteUrl,
    required this.picture,
    required this.position,
    required this.class1,
    required this.class2,
    required this.mapUrl,
    required this.travelInfo,
    required this.parkingInfo,
    required this.charge,
    required this.remarks,
    required this.cityId,
    required this.originalUpdateTime,
    required this.srcUpdateTime,
  });

  factory EventModel.fromTdx(TdxActivityTourismInfo tdx) {
    bool isEnglish(String str) {
      final validChars = RegExp(r'^[a-zA-Z0-9_\-=@,\.; ]+$');
      return validChars.hasMatch(str);
    }

    String fixString(String? str) {
      if (str == null || str.trim().isEmpty) {
        return '';
      } else if (str.trim() == '無') {
        return '';
      } else {
        return str.trim();
      }
    }

    String fixLocation(String location) {
      if (isEnglish(location)) {
        return Constants.CITY_ID_TO_STRING[location] ?? '';
      } else {
        return location;
      }
    }

    String fixAddress(String address) {
      if (isEnglish(address)) {
        return Constants.CITY_ID_TO_STRING[address] ?? '';
      } else {
        return address;
      }
    }

    String fixCity(String city) {
      return Constants.CITY_STRING_TO_ID[city.replaceAll('台', '臺')] ?? '';
    }

    String fixUrl(String url) {
      var strList = url.split('/');
      if (strList.length > 0) {
        var fileName = strList[strList.length - 1].toLowerCase();
        var extensionList = ['.jpg', '.jpeg', '.png'];
        for (int i = 0; i < extensionList.length; i++) {
          if (fileName.endsWith(extensionList[i])) {
            /// Get high quality images from https://www.trimt-nsa.gov.tw/ instead of thumbs.
            if (strList.length > 3 &&
                strList[2].compareTo('www.trimt-nsa.gov.tw') == 0) {
              return url.replaceAll('_thumb', '');
            } else {
              return url;
            }
          }
        }
      }
      return '';
    }

    String fixPhoneNumber(String phoneNum) {
      if (phoneNum.isNotEmpty) {
        if (phoneNum.startsWith('+886') || phoneNum.startsWith('886-')) {
          phoneNum = phoneNum.substring(4);
          return '+886-' + phoneNum;
        } else if (phoneNum.startsWith('+')) {
          return phoneNum;
        } else {
          return '+886-' + phoneNum;
        }
      }
      return phoneNum;
    }

    /// 開始與結束時間的校正：
    /// 在不受時區影響的狀態下，以台灣承辦人員的認知角度轉換成正確資料邏輯，最後再轉成UTC儲存。
    DateTime twStartTime = new DateFormat(Constants.EXPRESSION_TDX_DATA)
        .parse(fixString(tdx.startTime), true);
    DateTime twEndTime = new DateFormat(Constants.EXPRESSION_TDX_DATA)
        .parse(fixString(tdx.endTime), true);
    DateTime fixedTwStartTime;
    DateTime fixedTwEndTime;
    var duration = twEndTime.difference(twStartTime).inSeconds;
    int quotient = duration ~/ 86400;
    int remainder = duration % 86400;
    if (twStartTime.hour == 0 && twStartTime.minute == 0 && remainder == 0) {
      if (quotient == 1) {
        /// 單日全天活動有時會被正確輸入，不需要加一日。
        /// E.g.
        /// 5/2 00:00:?? - 5/3 00:00:?? >>> 5/2 00:00:00 - 5/3 00:00:00
        fixedTwStartTime =
            DateTime.utc(twStartTime.year, twStartTime.month, twStartTime.day);
        fixedTwEndTime =
            DateTime.utc(twEndTime.year, twEndTime.month, twEndTime.day);
      } else {
        /// 全天活動通常沒輸入時間，導致需要加一日。
        /// E.g.
        /// 5/2 00:00:?? - 5/2 00:00:?? >>> 5/2 00:00:00 - 5/3 00:00:00
        /// 5/2 00:00:?? - 5/9 00:00:?? >>> 5/2 00:00:00 - 5/10 00:00:00
        fixedTwStartTime =
            DateTime.utc(twStartTime.year, twStartTime.month, twStartTime.day);
        fixedTwEndTime =
            DateTime.utc(twEndTime.year, twEndTime.month, twEndTime.day)
                .add(Duration(days: 1));
      }
    } else if (twStartTime.hour == 0 &&
        twStartTime.minute == 0 &&
        86340 <= remainder &&
        remainder < 86400) {
      /// 多日全天活動通常沒輸入時間，導致需要加一日。
      /// 備註：未來如果出現正確輸入時間的多日全天活動，也會被誤加一日。
      /// E.g.
      /// 5/2 00:00:00 - 5/2 23:59:00 >>> 5/2 00:00:00 - 5/3 00:00:00
      /// 5/2 00:00:00 - 5/9 23:59:59 >>> 5/2 00:00:00 - 5/10 00:00:00
      fixedTwStartTime =
          DateTime.utc(twStartTime.year, twStartTime.month, twStartTime.day);
      fixedTwEndTime =
          DateTime.utc(twEndTime.year, twEndTime.month, twEndTime.day)
              .add(Duration(days: 1));
    } else {
      /// 有正確時間戳記的活動，無需處理。
      /// E.g.
      /// 5/2 10:00:00 - 5/2 18:00:00
      /// 5/2 10:00:00 - 5/9 18:00:00
      fixedTwStartTime = twStartTime;
      fixedTwEndTime = twEndTime;
    }

    var pictureUrl1 = fixUrl(fixString(tdx.picture!.pictureUrl1));
    var pictureDescription1 = fixString(tdx.picture!.pictureDescription1);
    var pictureUrl2 = fixUrl(fixString(tdx.picture!.pictureUrl2));
    var pictureDescription2 = fixString(tdx.picture!.pictureDescription2);
    var pictureUrl3 = fixUrl(fixString(tdx.picture!.pictureUrl3));
    var pictureDescription3 = fixString(tdx.picture!.pictureDescription3);
    List<TdxPicture> tdxPictureList = <TdxPicture>[];
    if (pictureUrl1.isNotEmpty || pictureDescription1.isNotEmpty) {
      tdxPictureList.add(TdxPicture(pictureUrl1, pictureDescription1));
    }
    if (pictureUrl2.isNotEmpty || pictureDescription2.isNotEmpty) {
      tdxPictureList.add(TdxPicture(pictureUrl2, pictureDescription2));
    }
    if (pictureUrl3.isNotEmpty || pictureDescription3.isNotEmpty) {
      tdxPictureList.add(TdxPicture(pictureUrl3, pictureDescription3));
    }

    return EventModel(
      srcType: Constants.SOURCE_TDX,
      srcId: fixString(tdx.id),
      name: fixString(tdx.name),
      description: fixString(tdx.description),
      participation: fixString(tdx.participation),
      location: fixLocation(fixString(tdx.location)),
      address: fixAddress(fixString(tdx.address)),
      phone: fixPhoneNumber(fixString(tdx.phone)),
      organizer: fixString(tdx.organizer),
      startTime: fixedTwStartTime.add(Duration(hours: -8)),
      endTime: fixedTwEndTime.add(Duration(hours: -8)),
      cycle: fixString(tdx.cycle),
      nonCycle: fixString(tdx.nonCycle),
      websiteUrl: fixString(tdx.websiteUrl),
      picture: new TourismPicture(tdxPictureList),
      position: new PointType(
        positionLon: tdx.position!.positionLon ?? 0,
        positionLat: tdx.position!.positionLat ?? 0,
        geoHash: fixString(tdx.position!.geoHash),
      ),
      class1: fixString(tdx.class1),
      class2: fixString(tdx.class2),
      mapUrl: fixString(tdx.mapUrl),
      travelInfo: fixString(tdx.travelInfo),
      parkingInfo: fixString(tdx.parkingInfo),
      charge: fixString(tdx.charge),
      remarks: fixString(tdx.remarks),
      cityId: fixCity(fixString(tdx.city)),
      originalUpdateTime: new DateFormat(Constants.EXPRESSION_TDX_DATA)
          .parse(fixString(tdx.srcUpdateTime), true)
          .add(Duration(hours: -8)),
      srcUpdateTime: new DateFormat(Constants.EXPRESSION_TDX_DATA)
          .parse(fixString(tdx.updateTime), true)
          .add(Duration(hours: -8)),
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseHelper.COLUMN_SRC_TYPE: srcType,
      DatabaseHelper.COLUMN_SRC_ID: srcId,
      DatabaseHelper.COLUMN_NAME: name,
      DatabaseHelper.COLUMN_DESCRIPTION: description,
      DatabaseHelper.COLUMN_PARTICIPATION: participation,
      DatabaseHelper.COLUMN_LOCATION: location,
      DatabaseHelper.COLUMN_ADDRESS: address,
      DatabaseHelper.COLUMN_PHONE: phone,
      DatabaseHelper.COLUMN_ORGANIZER: organizer,
      DatabaseHelper.COLUMN_START_TIME: startTime.toIso8601String(),
      DatabaseHelper.COLUMN_END_TIME: endTime.toIso8601String(),
      DatabaseHelper.COLUMN_CYCLE: cycle,
      DatabaseHelper.COLUMN_NON_CYCLE: nonCycle,
      DatabaseHelper.COLUMN_WEBSITE_URL: websiteUrl,
      DatabaseHelper.COLUMN_POSITION_LON: position.positionLon,
      DatabaseHelper.COLUMN_POSITION_LAT: position.positionLat,
      DatabaseHelper.COLUMN_POSITION_GEO_HASH: position.geoHash,
      DatabaseHelper.COLUMN_CLASS_1: class1,
      DatabaseHelper.COLUMN_CLASS_2: class2,
      DatabaseHelper.COLUMN_MAP_URL: mapUrl,
      DatabaseHelper.COLUMN_TRAVEL_INFO: travelInfo,
      DatabaseHelper.COLUMN_PARKING_INFO: parkingInfo,
      DatabaseHelper.COLUMN_CHARGE: charge,
      DatabaseHelper.COLUMN_REMARKS: remarks,
      DatabaseHelper.COLUMN_CITY_ID: cityId,
      DatabaseHelper.COLUMN_SRC_UPDATE_TIME:
          originalUpdateTime.toIso8601String(),
      DatabaseHelper.COLUMN_TDX_UPDATE_TIME: srcUpdateTime.toIso8601String(),
      DatabaseHelper.COLUMN_STATUS: status,
    };
    if (dbId >= 0) {
      map[DatabaseHelper.COLUMN_ID] = dbId;
    }
    return map;
  }

  EventModel.fromMap(Map<String, dynamic> map) {
    dbId = map[DatabaseHelper.COLUMN_ID];
    srcType = map[DatabaseHelper.COLUMN_SRC_TYPE];
    srcId = map[DatabaseHelper.COLUMN_SRC_ID];
    name = map[DatabaseHelper.COLUMN_NAME];
    description = map[DatabaseHelper.COLUMN_DESCRIPTION];
    participation = map[DatabaseHelper.COLUMN_PARTICIPATION];
    location = map[DatabaseHelper.COLUMN_LOCATION];
    address = map[DatabaseHelper.COLUMN_ADDRESS];
    phone = map[DatabaseHelper.COLUMN_PHONE];
    organizer = map[DatabaseHelper.COLUMN_ORGANIZER];
    startTime = DateTime.parse(map[DatabaseHelper.COLUMN_START_TIME]);
    endTime = DateTime.parse(map[DatabaseHelper.COLUMN_END_TIME]);
    cycle = map[DatabaseHelper.COLUMN_CYCLE];
    nonCycle = map[DatabaseHelper.COLUMN_NON_CYCLE];
    websiteUrl = map[DatabaseHelper.COLUMN_WEBSITE_URL];
    picture = TourismPicture(<TdxPicture>[]);
    position = PointType(
        positionLon: map[DatabaseHelper.COLUMN_POSITION_LON],
        positionLat: map[DatabaseHelper.COLUMN_POSITION_LAT],
        geoHash: map[DatabaseHelper.COLUMN_POSITION_GEO_HASH]);
    class1 = map[DatabaseHelper.COLUMN_CLASS_1];
    class2 = map[DatabaseHelper.COLUMN_CLASS_2];
    mapUrl = map[DatabaseHelper.COLUMN_MAP_URL];
    travelInfo = map[DatabaseHelper.COLUMN_TRAVEL_INFO];
    parkingInfo = map[DatabaseHelper.COLUMN_PARKING_INFO];
    charge = map[DatabaseHelper.COLUMN_CHARGE];
    remarks = map[DatabaseHelper.COLUMN_REMARKS];
    cityId = map[DatabaseHelper.COLUMN_CITY_ID];
    originalUpdateTime =
        DateTime.parse(map[DatabaseHelper.COLUMN_SRC_UPDATE_TIME]);
    srcUpdateTime = DateTime.parse(map[DatabaseHelper.COLUMN_TDX_UPDATE_TIME]);
    status = map[DatabaseHelper.COLUMN_STATUS];
  }
}

class TourismPicture {
  List<TdxPicture> tdxPictureList = <TdxPicture>[];

  TourismPicture(
    this.tdxPictureList,
  );

  List<Map<String, dynamic>> toMapList(String srcType, String srcId) {
    List<Map<String, dynamic>> mapList = <Map<String, dynamic>>[];
    for (int i = 0; i < tdxPictureList.length; i++) {
      var map = <String, dynamic>{
        DatabaseHelper.COLUMN_SRC_TYPE: srcType,
        DatabaseHelper.COLUMN_SRC_ID: srcId,
        DatabaseHelper.COLUMN_NUMBER: i + 1,
        DatabaseHelper.COLUMN_URL: tdxPictureList[i].url,
        DatabaseHelper.COLUMN_DESCRIPTION: tdxPictureList[i].description,
      };
      mapList.add(map);
    }
    return mapList;
  }

  TourismPicture.fromMapList(List<Map<String, dynamic>> mapList) {
    mapList.forEach((map) {
      if (map[DatabaseHelper.COLUMN_SRC_TYPE] == Constants.SOURCE_TDX) {
        tdxPictureList.add(TdxPicture(map[DatabaseHelper.COLUMN_URL],
            map[DatabaseHelper.COLUMN_DESCRIPTION]));
      }
    });
  }
}

class TdxPicture {
  String url = '';
  String description = '';

  TdxPicture(
    this.url,
    this.description,
  );
}

class PointType {
  double positionLon = 0; // 位置經度(WGS84)
  double positionLat = 0; // 位置緯度(WGS84)
  String geoHash = ''; // 地理空間編碼

  PointType({
    required this.positionLon,
    required this.positionLat,
    required this.geoHash,
  });
}
