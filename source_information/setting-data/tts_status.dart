class TtsTrangthai {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  String? statusName;
  int? active;

  TtsTrangthai({this.id, this.modifiedUser, this.modifiedDate, this.createdUser, this.createdDate, this.statusName, this.active});

  factory TtsTrangthai.fromJson(Map<String, dynamic> json) {
    return TtsTrangthai(
        id: json['id'],
        modifiedUser: json['modifiedUser'],
        modifiedDate: json['modifiedDate'],
        createdUser: json['createdUser'],
        createdDate: json['createdDate'],
        statusName: json['statusName'] ?? "",
        active: json['active']);
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
}
