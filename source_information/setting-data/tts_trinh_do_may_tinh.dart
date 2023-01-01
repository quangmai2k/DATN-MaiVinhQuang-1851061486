class TrinhDoMayTinhTTS {
  int? id;
  // int? modifiedUser;
  // String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  int? ttsId;
  int? formId;
  int? internetEmail;
  int? msWord;
  int? msExcel;
  int? autoCad;
  int? cam;
  int? catia;
  int? otherType;
  String? otherName;
  int? otherLevel;

  TrinhDoMayTinhTTS(
      {this.id,
      // this.modifiedUser,
      // this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.ttsId,
      this.formId,
      this.internetEmail,
      this.msWord,
      this.msExcel,
      this.autoCad,
      this.cam,
      this.catia,
      this.otherType,
      this.otherName,
      this.otherLevel});

  factory TrinhDoMayTinhTTS.fromJson(Map<String, dynamic> json) {
    return TrinhDoMayTinhTTS(
      id: json['id'],
      // modifiedUser: json['modifiedUser'],
      // modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      ttsId: json['ttsId'],
      formId: json['formId'],
      internetEmail: json['internetEmail'],
      msWord: json['msWord'],
      msExcel: json['msExcel'],
      autoCad: json['autoCad'],
      cam: json['cam'],
      catia: json['catia'],
      otherType: json['otherType'],
      otherName: json['otherName'],
      otherLevel: json['otherLevel'],
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
    data['internetEmail'] = this.internetEmail;
    data['msWord'] = this.msWord;
    data['msExcel'] = this.msExcel;
    data['autoCad'] = this.autoCad;
    data['cam'] = this.cam;
    data['catia'] = this.catia;
    data['otherType'] = this.otherType;
    data['otherName'] = this.otherName;
    data['otherLevel'] = this.otherLevel;
    return data;
  }
}
