class CwbElementValue {
  final String? value; // 資料值
  final String? measures; // 資料度量單位

  CwbElementValue({
    this.value,
    this.measures,
  });

  factory CwbElementValue.fromJson(Map<String, dynamic> j) {
    return CwbElementValue(
      value: j['value'],
      measures: j['measures'],
    );
  }
}
