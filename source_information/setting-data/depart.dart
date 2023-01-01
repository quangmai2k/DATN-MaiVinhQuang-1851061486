class Phongban {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  String? departName;
  int? parentId;
  String? defaultPage;
  int? status;

  Phongban(
      {this.id,
      this.modifiedUser,
      this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.departName,
      this.parentId,
      this.defaultPage,
      this.status});

  factory Phongban.fromJson(Map<String, dynamic> json) {
    return Phongban(
      id: json['id'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      departName: json['departName'],
      parentId: json['parentId'],
      defaultPage: json['defaultPage'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['modifiedUser'] = this.modifiedUser;
    data['modifiedDate'] = this.modifiedDate;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['departName'] = this.departName;
    data['parentId'] = this.parentId;
    data['defaultPage'] = this.defaultPage;
    data['status'] = this.status;
    return data;
  }
}
