import 'package:intl/intl.dart';
import 'package:taiwantourism/model/ptx_activity_tourism_info.dart';

class ActivityTourismInfo {
  String id; // 活動訊息代碼
  String name; // 活動名稱
  String description; // 活動簡述
  String location; // 主要活動地點名稱
  String address; // 主要活動地點地址
  String phone; // 活動聯絡電話
  String organizer; // 活動主辦單位
  DateTime startTime; // 活動開始時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  DateTime endTime; // 活動結束時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  String websiteUrl; // 活動網址
  TourismPicture picture; // 活動照片
  PointType position; // 活動位置
  String mapUrl; // 活動地圖/簡圖連結網址
  String remarks; // 備註(其他活動相關事項)
  String city; // 所屬縣市
  DateTime srcUpdateTime; // 觀光局檔案更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  DateTime updateTime; // 本平台資料更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)

  ActivityTourismInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.phone,
    required this.organizer,
    required this.startTime,
    required this.endTime,
    required this.websiteUrl,
    required this.picture,
    required this.position,
    required this.mapUrl,
    required this.remarks,
    required this.city,
    required this.srcUpdateTime,
    required this.updateTime,
  });

  factory ActivityTourismInfo.fromPtx(PtxActivityTourismInfo ptx) {
    String fixString(String? str) {
      if (str == null || str.trim().isEmpty) {
        return '';
      } else if (str.trim() == '無') {
        return '';
      } else {
        return str.trim();
      }
    }

    String fixUrl(String url) {
      if (url.isNotEmpty && url.split('/').length > 0) {
        var strList = url.split('/');

        /// Get high quality images from https://www.trimt-nsa.gov.tw/ instead of thumbs.
        if (strList.length > 3 &&
            strList[2].compareTo('www.trimt-nsa.gov.tw') == 0) {
          return url.replaceAll('_thumb', '');
        }
      }
      return url;
    }

    String fixPhoneNumber(String phoneNum) {
      if (phoneNum.isNotEmpty && phoneNum.startsWith('886-')) {
        return phoneNum.substring(4);
      }
      return phoneNum;
    }

    DateTime rawStartTime =
        new DateFormat('yyyy-MM-ddTHH:mm:ss').parse(fixString(ptx.startTime));
    DateTime rawEndTime =
        new DateFormat('yyyy-MM-ddTHH:mm:ss').parse(fixString(ptx.endTime));
    DateTime fixedStartTime;
    DateTime fixedEndTime;
    var duration = rawEndTime.difference(rawStartTime).inSeconds;
    int quotient = duration ~/ 86400;
    int remainder = duration % 86400;
    if (rawStartTime.hour == 0 && rawStartTime.minute == 0 && remainder == 0) {
      if (quotient == 1) {
        /// 單日全天活動有時會被正確輸入，不需要加一日。
        /// E.g.
        /// 5/2 00:00:?? - 5/3 00:00:?? >>> 5/2 00:00:00 - 5/3 00:00:00
        fixedStartTime =
            DateTime(rawStartTime.year, rawStartTime.month, rawStartTime.day);
        fixedEndTime =
            DateTime(rawEndTime.year, rawEndTime.month, rawEndTime.day);
      } else {
        /// 全天活動通常沒輸入時間，導致需要加一日。
        /// E.g.
        /// 5/2 00:00:?? - 5/2 00:00:?? >>> 5/2 00:00:00 - 5/3 00:00:00
        /// 5/2 00:00:?? - 5/9 00:00:?? >>> 5/2 00:00:00 - 5/10 00:00:00
        fixedStartTime =
            DateTime(rawStartTime.year, rawStartTime.month, rawStartTime.day);
        fixedEndTime =
            DateTime(rawEndTime.year, rawEndTime.month, rawEndTime.day)
                .add(Duration(days: 1));
      }
    } else if (rawStartTime.hour == 0 &&
        rawStartTime.minute == 0 &&
        86340 <= remainder &&
        remainder < 86400) {
      /// 多日全天活動通常沒輸入時間，導致需要加一日。
      /// 備註：未來如果出現正確輸入時間的多日全天活動，也會被誤加一日。
      /// E.g.
      /// 5/2 00:00:00 - 5/2 23:59:00 >>> 5/2 00:00:00 - 5/3 00:00:00
      /// 5/2 00:00:00 - 5/9 23:59:59 >>> 5/2 00:00:00 - 5/10 00:00:00
      fixedStartTime =
          DateTime(rawStartTime.year, rawStartTime.month, rawStartTime.day);
      fixedEndTime = DateTime(rawEndTime.year, rawEndTime.month, rawEndTime.day)
          .add(Duration(days: 1));
    } else {
      /// 有正確時間戳記的活動，無需處理。
      /// E.g.
      /// 5/2 10:00:00 - 5/2 18:00:00
      /// 5/2 10:00:00 - 5/9 18:00:00
      fixedStartTime = rawStartTime;
      fixedEndTime = rawEndTime;
    }

    return ActivityTourismInfo(
        id: fixString(ptx.id),
        name: fixString(ptx.name),
        description: fixString(ptx.description),
        location: fixString(ptx.location),
        address: fixString(ptx.address),
        phone: fixPhoneNumber(fixString(ptx.phone)),
        organizer: fixString(ptx.organizer),
        startTime: fixedStartTime.toUtc(),
        endTime: fixedEndTime.toUtc(),
        websiteUrl: fixString(ptx.websiteUrl),
        picture: new TourismPicture(
          pictureUrl1: fixUrl(fixString(ptx.picture!.pictureUrl1)),
          pictureDescription1: fixString(ptx.picture!.pictureDescription1),
          pictureUrl2: fixUrl(fixString(ptx.picture!.pictureUrl2)),
          pictureDescription2: fixString(ptx.picture!.pictureDescription2),
          pictureUrl3: fixUrl(fixString(ptx.picture!.pictureUrl3)),
          pictureDescription3: fixString(ptx.picture!.pictureDescription3),
        ),
        position: new PointType(
          positionLon: ptx.position!.positionLon ?? 0,
          positionLat: ptx.position!.positionLat ?? 0,
          geoHash: fixString(ptx.position!.geoHash),
        ),
        mapUrl: fixString(ptx.mapUrl),
        remarks: fixString(ptx.remarks),
        city: fixString(ptx.city),
        srcUpdateTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(fixString(ptx.srcUpdateTime))
            .toUtc(),
        updateTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(fixString(ptx.updateTime))
            .toUtc());
  }
}

class TourismPicture {
  String pictureUrl1; // 照片連結網址1
  String pictureDescription1; // 照片說明1
  String pictureUrl2; // 照片連結網址2
  String pictureDescription2; // 照片說明2
  String pictureUrl3; // 照片連結網址3
  String pictureDescription3; // 照片說明3

  TourismPicture({
    required this.pictureUrl1,
    required this.pictureDescription1,
    required this.pictureUrl2,
    required this.pictureDescription2,
    required this.pictureUrl3,
    required this.pictureDescription3,
  });
}

class PointType {
  double positionLon; // 位置經度(WGS84)
  double positionLat; // 位置緯度(WGS84)
  String geoHash; // 地理空間編碼

  PointType({
    required this.positionLon,
    required this.positionLat,
    required this.geoHash,
  });
}
