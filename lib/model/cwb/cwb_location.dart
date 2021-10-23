import 'cwb_weather_element.dart';

class CwbLocation {
  final String? locationName; // 地點名稱
  final String? geoCode; // 地理分區編碼
  final String? lat; // 緯度
  final String? lon; // 經度
  final List<CwbWeatherElement?>? weatherElement; // 氣象要素

  CwbLocation({
    this.locationName,
    this.geoCode,
    this.lat,
    this.lon,
    this.weatherElement,
  });

  factory CwbLocation.fromJson(Map<String, dynamic> j) {
    final weatherElement = j['weatherElement'] as List<dynamic>?;
    return CwbLocation(
      locationName: j['locationName'],
      geoCode: j['geocode'],
      lat: j['lat'],
      lon: j['lon'],
      weatherElement: weatherElement != null
          ? weatherElement.map((s) => CwbWeatherElement.fromJson(s)).toList()
          : <CwbWeatherElement?>[],
    );
  }
}
