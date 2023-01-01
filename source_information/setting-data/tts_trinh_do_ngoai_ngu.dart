class TrinhDoNgoaiNguTTS {
  int? id;
  // int? modifiedUser;
  // String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  int? ttsId;
  int? formId;
  int? english;
  int? japanese;

  TrinhDoNgoaiNguTTS(
      {this.id,
      // this.modifiedUser,
      // this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.ttsId,
      this.formId,
      this.english,
      this.japanese});

  factory TrinhDoNgoaiNguTTS.fromJson(Map<String, dynamic> json) {
    return TrinhDoNgoaiNguTTS(
      id: json['id'],
      // modifiedUser: json['modifiedUser'],
      // modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      ttsId: json['ttsId'],
      formId: json['formId'],
      english: json['english'],
      japanese: json['japanese'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    // data['modifiedUser'] = this.modifiedUser;
    // data['modifiedDate'] = this.modifiedDate;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['ttsId'] = this.ttsId;
    data['formId'] = this.formId;
    data['english'] = this.english;
    data['japanese'] = this.japanese;
    return data;
  }
}
