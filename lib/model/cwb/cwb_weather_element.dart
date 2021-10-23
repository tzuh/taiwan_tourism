import 'cwb_time.dart';

class CwbWeatherElement {
  final String? elementName; // (氣象)要素名稱
  final String? description; // (氣象)要素描述
  final List<CwbTime?>? time; // 時間

  CwbWeatherElement({
    this.elementName,
    this.description,
    this.time,
  });

  factory CwbWeatherElement.fromJson(Map<String, dynamic> j) {
    final time = j['time'] as List<dynamic>?;
    return CwbWeatherElement(
      elementName: j['elementName'],
      description: j['description'],
      time: time != null
          ? time.map((s) => CwbTime.fromJson(s)).toList()
          : <CwbTime?>[],
    );
  }
}
