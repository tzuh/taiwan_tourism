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
    String fixUrl(String url) {
      if (url.isNotEmpty && url.split('/').length > 0) {
        var strList = url.split('/');

        /// Get high quality images from https://www.trimt-nsa.gov.tw/ instead of thumbs.
        if (strList.length > 3 &&
            strList[2].compareTo('www.trimt-nsa.gov.tw') == 0) {
          print('Remove _thumb of ${ptx.id}: ${url.replaceAll('_thumb', '')}');
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

    return ActivityTourismInfo(
        id: ptx.id?.trim() ?? '',
        name: ptx.name?.trim() ?? '',
        description: ptx.description?.trim() ?? '',
        location: ptx.location?.trim() ?? '',
        address: ptx.address?.trim() ?? '',
        phone: fixPhoneNumber(ptx.phone?.trim() ?? ''),
        organizer: ptx.organizer?.trim() ?? '',
        startTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(ptx.startTime?.trim() ?? '')
            .toUtc(),
        endTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(ptx.endTime?.trim() ?? '')
            .toUtc(),
        websiteUrl: ptx.websiteUrl?.trim() ?? '',
        picture: new TourismPicture(
          pictureUrl1: fixUrl(ptx.picture!.pictureUrl1?.trim() ?? ''),
          pictureDescription1: ptx.picture!.pictureDescription1?.trim() ?? '',
          pictureUrl2: fixUrl(ptx.picture!.pictureUrl2?.trim() ?? ''),
          pictureDescription2: ptx.picture!.pictureDescription2?.trim() ?? '',
          pictureUrl3: fixUrl(ptx.picture!.pictureUrl3?.trim() ?? ''),
          pictureDescription3: ptx.picture!.pictureDescription3?.trim() ?? '',
        ),
        position: new PointType(
          positionLon: ptx.position!.positionLon ?? 0,
          positionLat: ptx.position!.positionLat ?? 0,
          geoHash: ptx.position!.geoHash?.trim() ?? '',
        ),
        mapUrl: ptx.mapUrl?.trim() ?? '',
        remarks: ptx.remarks?.trim() ?? '',
        city: ptx.city?.trim() ?? '',
        srcUpdateTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(ptx.srcUpdateTime?.trim() ?? '')
            .toUtc(),
        updateTime: new DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(ptx.updateTime?.trim() ?? '')
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
