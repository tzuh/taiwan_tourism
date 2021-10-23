class PtxTourismPicture {
  final String? pictureUrl1; // 照片連結網址1
  final String? pictureDescription1; // 照片說明1
  final String? pictureUrl2; // 照片連結網址2
  final String? pictureDescription2; // 照片說明2
  final String? pictureUrl3; // 照片連結網址3
  final String? pictureDescription3; // 照片說明3

  PtxTourismPicture({
    this.pictureUrl1,
    this.pictureDescription1,
    this.pictureUrl2,
    this.pictureDescription2,
    this.pictureUrl3,
    this.pictureDescription3,
  });

  factory PtxTourismPicture.fromJson(Map<String, dynamic> json) {
    return PtxTourismPicture(
      pictureUrl1: json['PictureUrl1'],
      pictureDescription1: json['PictureDescription1'],
      pictureUrl2: json['PictureUrl2'],
      pictureDescription2: json['PictureDescription2'],
      pictureUrl3: json['PictureUrl3'],
      pictureDescription3: json['PictureDescription3'],
    );
  }
}
