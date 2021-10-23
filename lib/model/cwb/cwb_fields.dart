class CwbFields {
  final String? id;
  final String? type;

  CwbFields({
    this.id,
    this.type,
  });

  factory CwbFields.fromJson(Map<String, dynamic> j) {
    return CwbFields(
      id: j['id'],
      type: j['type'],
    );
  }
}
