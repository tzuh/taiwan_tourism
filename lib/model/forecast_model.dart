class ForecastModel {
  static const int INT_NONE = -999;
  static const double FLOAT_NONE = -999;

  int dbId = -1; // App資料庫ID
  late String srcType;
  late String srcId;
  late String cityId;
  late String locationName; // 鄉鎮區名稱
  double positionLat = FLOAT_NONE; // 緯度
  double positionLon = FLOAT_NONE; // 經度
  String geoCode = ''; // 地理分區編碼
  late DateTime startTime; // 開始時間 (UTC)
  late DateTime endTime; // 結束時間 (UTC)
  String wx = ''; // 天氣現象
  int maxT = INT_NONE; // 最高溫度 (攝氏度)
  int minT = INT_NONE; // 最低溫度 (攝氏度)
  int pOP = INT_NONE; // 降雨機率 (%)

  ForecastModel({
    required this.srcType,
    required this.srcId,
    required this.cityId,
    required this.locationName,
    required this.startTime,
    required this.endTime,
  });
}
