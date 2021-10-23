import 'cwb_result.dart';
import 'cwb_records.dart';

class CwbResponseBody {
  final String? success;
  final CwbResult? result;
  final CwbRecords? records;

  CwbResponseBody({
    this.success,
    this.result,
    this.records,
  });

  factory CwbResponseBody.fromJson(Map<String, dynamic> j) {
    return CwbResponseBody(
      success: j['success'],
      result: CwbResult.fromJson(j['result']),
      records: CwbRecords.fromJson(j['records']),
    );
  }
}
