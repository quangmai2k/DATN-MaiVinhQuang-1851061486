//Dân tộc
class PolkData {
  int? id;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? folkName;
  int? status;

  PolkData({this.id, this.createdUser, this.createdDate, this.deleted, this.folkName, this.status});

  factory PolkData.fromJson(Map<String, dynamic> json) {
    return PolkData(
      id: json['id'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      folkName: json['folkName'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['folkName'] = this.folkName;
    data['status'] = this.status;
    return data;
  }
}
