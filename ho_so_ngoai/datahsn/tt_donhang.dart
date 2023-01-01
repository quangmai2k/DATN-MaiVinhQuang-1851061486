class TrangThaiDH {
  int id;
  String statusName;

  TrangThaiDH({
    required this.id,
    required this.statusName,
  });

  factory TrangThaiDH.fromJson(Map<dynamic, dynamic> json) {
    return TrangThaiDH(
      id: json['id'] ?? 0,
      statusName: json['statusName'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'statusName': statusName,
    };
  }
}
