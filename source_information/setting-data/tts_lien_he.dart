class LienHeTTS {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  int? ttsId;
  String? name;
  String? address;
  String? relation;
  String? phone;
  String? facebook;
  String? skype;

  LienHeTTS(
      {this.id,
      this.modifiedUser,
      this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.ttsId,
      this.name,
      this.address,
      this.relation,
      this.phone,
      this.facebook,
      this.skype});

  factory LienHeTTS.fromJson(Map<String, dynamic> json) {
    return LienHeTTS(
      id: json['id'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      ttsId: json['ttsId'],
      name: json['name'],
      address: json['address'],
      relation: json['relation'],
      phone: json['phone'],
      facebook: json['facebook'],
      skype: json['skype'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['modifiedUser'] = this.modifiedUser;
    data['modifiedDate'] = this.modifiedDate;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['ttsId'] = this.ttsId;
    data['name'] = this.name;
    data['address'] = this.address;
    data['relation'] = this.relation;
    data['phone'] = this.phone;
    data['facebook'] = this.facebook;
    data['skype'] = this.skype;
    return data;
  }
}
