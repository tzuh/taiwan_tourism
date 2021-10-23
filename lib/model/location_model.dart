class LocationModel {
  static const double FLOAT_NONE = -999;

  int dbId = -1; // App資料庫ID
  String name = ''; // 鄉鎮區名稱
  double positionLat = FLOAT_NONE; // 緯度
  double positionLon = FLOAT_NONE; // 經度
  String geoCode = ''; // 地理分區編碼

  LocationModel({
    required this.name,
    required this.positionLat,
    required this.positionLon,
    required this.geoCode,
  });
}
