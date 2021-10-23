import 'cwb_fields.dart';

class CwbResult {
  final String? resourceId;
  final List<CwbFields?>? fields;

  CwbResult({
    this.resourceId,
    this.fields,
  });

  factory CwbResult.fromJson(Map<String, dynamic> j) {
    final fields = j['fields'] as List<dynamic>?;
    return CwbResult(
      resourceId: j['resource_id'],
      fields: fields != null
          ? fields.map((s) => CwbFields.fromJson(s)).toList()
          : <CwbFields?>[],
    );
  }
}
