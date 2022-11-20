class TdxTokenInfo {
  final String? accessToken; // 活動訊息代碼
  final int? expiresIn; // 活動名稱
  final String? tokenType; // 活動簡述

  TdxTokenInfo({
    this.accessToken,
    this.expiresIn,
    this.tokenType,
  });

  factory TdxTokenInfo.fromJson(Map<String, dynamic> json) {
    return TdxTokenInfo(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
    );
  }
}
