class TrangThai {
  int id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  String statusName;
  int? active;

  TrangThai({
    required this.id,
    this.modifiedUser,
    this.modifiedDate,
    this.createdUser,
    this.createdDate,
    required this.statusName,
    this.active,
  });

  factory TrangThai.fromJson(Map<dynamic, dynamic> json) {
    return TrangThai(
      id: json['id'] ?? 0,
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      statusName: json['statusName'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['modifiedUser'] = this.modifiedUser;
    data['modifiedDate'] = this.modifiedDate;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['statusName'] = this.statusName;
    data['active'] = this.active;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'statusName': statusName,
    };
  }
}
