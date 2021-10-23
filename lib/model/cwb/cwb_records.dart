import 'cwb_locations.dart';

class CwbRecords {
  final List<CwbLocations?>? locations; // 地點集合

  CwbRecords({this.locations});

  factory CwbRecords.fromJson(Map<String, dynamic> j) {
    final locations = j['locations'] as List<dynamic>?;
    return CwbRecords(
      locations: locations != null
          ? locations.map((s) => CwbLocations.fromJson(s)).toList()
          : <CwbLocations?>[],
    );
  }
}
