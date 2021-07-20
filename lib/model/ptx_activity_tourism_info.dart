import 'dart:convert';

import 'package:taiwantourism/model/ptx_point_type.dart';
import 'package:taiwantourism/model/ptx_tourism_picture.dart';

class PtxActivityTourismInfo {
  final String? id; // 活動訊息代碼
  final String? name; // 活動名稱
  final String? description; // 活動簡述
  final String? participation; // 活動參與對象
  final String? location; // 主要活動地點名稱
  final String? address; // 主要活動地點地址
  final String? phone; // 活動聯絡電話
  final String? organizer; // 活動主辦單位
  final String? startTime; // 活動開始時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  final String? endTime; // 活動結束時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  final String? cycle; // 週期性活動執行時間
  final String? nonCycle; // 非週期性活動執行時間
  final String? websiteUrl; // 活動網址
  final PtxTourismPicture? picture; // 活動照片
  final PtxPointType? position; // 活動位置
  final String? class1; // 活動分類1
  final String? class2; // 活動分類2
  final String? mapUrl; // 活動地圖/簡圖連結網址
  final String? travelInfo; // 交通資訊
  final String? parkingInfo; // 停車資訊
  final String? charge; // 費用標示
  final String? remarks; // 備註(其他活動相關事項)
  final String? city; // 所屬縣市
  final String? srcUpdateTime; // 觀光局檔案更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
  final String? updateTime; // 本平台資料更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)

  PtxActivityTourismInfo({
    this.id,
    this.name,
    this.description,
    this.participation,
    this.location,
    this.address,
    this.phone,
    this.organizer,
    this.startTime,
    this.endTime,
    this.cycle,
    this.nonCycle,
    this.websiteUrl,
    this.picture,
    this.position,
    this.class1,
    this.class2,
    this.mapUrl,
    this.travelInfo,
    this.parkingInfo,
    this.charge,
    this.remarks,
    this.city,
    this.srcUpdateTime,
    this.updateTime,
  });
  
  factory PtxActivityTourismInfo.fromJson(Map<String, dynamic> json) {
    return PtxActivityTourismInfo(
      id: json['ID'],
      name: json['Name'],
      description: json['Description'],
      participation: json['Particpation'],
      location: json['Location'],
      address: json['Address'],
      phone: json['Phone'],
      organizer: json['Organizer'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      cycle: json['Cycle'],
      nonCycle: json['NonCycle'],
      websiteUrl: json['WebsiteUrl'],
      picture: PtxTourismPicture.fromJson(json['Picture']),
      position: PtxPointType.fromJson(json['Position']),
      class1: json['Class1'],
      class2: json['Class2'],
      mapUrl: json['MapUrl'],
      travelInfo: json['TravelInfo'],
      parkingInfo: json['ParkingInfo'],
      charge: json['Charge'],
      remarks: json['Remarks'],
      city: json['City'],
      srcUpdateTime: json['SrcUpdateTime'],
      updateTime: json['UpdateTime'],
    );
  }
}
