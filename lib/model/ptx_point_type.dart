class PtxPointType {
  final double? positionLon; // 位置經度(WGS84)
  final double? positionLat; // 位置緯度(WGS84)
  final String? geoHash; // 地理空間編碼

  PtxPointType({
    this.positionLon,
    this.positionLat,
    this.geoHash,
  });

  factory PtxPointType.fromJson(Map<String, dynamic> json) {
    return PtxPointType(
      positionLon: json['PositionLon'],
      positionLat: json['PositionLat'],
      geoHash: json['GeoHash'],
    );
  }
}
