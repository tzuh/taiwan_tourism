import 'cwb_element_value.dart';

class CwbTime {
  final String? startTime; // 資料開始時間 (UTC+8)
  final String? endTime; // 資料結束時間 (UTC+8)
  final List<CwbElementValue?>? elementValue; // (氣象)要素值

  CwbTime({
    this.startTime,
    this.endTime,
    this.elementValue,
  });

  factory CwbTime.fromJson(Map<String, dynamic> j) {
    final elementValue = j['elementValue'] as List<dynamic>?;
    return CwbTime(
      startTime: j['startTime'],
      endTime: j['endTime'],
      elementValue: elementValue != null
          ? elementValue.map((s) => CwbElementValue.fromJson(s)).toList()
          : <CwbElementValue?>[],
    );
  }
}
