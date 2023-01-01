import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/polk.dart';

import 'certificate.dart';

class TTSFormChiTiet {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  int? formId;
  // Form? form;
  int? ttsId;
  // Nguoidung? nguoidung;
  int? academicId;
  Certificate? trinhdohocvan;
  int? folkId;
  PolkData? dantoc;
  int? religionId;
  int? nurtured;
  int? livedInGroup;
  int? cook;
  String? personalityTrength;
  String? personalityWeakness;
  String? hobby;
  String? personalityAssessment;
  String? specialize;
  String? reasonGoJapan;
  int? japanVisaApplied;
  int? personalIncome;
  int? familyIncome;
  int? abroadEver;
  int? abroadCountryId;
  String? abroadCountryDate;
  int? desiredIncome;
  String? desiredIncome3Years;
  String? cumulativePoint;
  String? iqPoint;
  String? workTime;
  String? workAddress;
  String? desiredProfessionJapanDescription;
  String? workAfterContractExpired;
  int? familyAgreement;
  String? jobId;

  TTSFormChiTiet(
      {this.id,
      this.modifiedUser,
      this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.formId,
      // this.form,
      this.ttsId,
      // this.nguoidung,
      this.academicId,
      this.trinhdohocvan,
      this.folkId,
      this.dantoc,
      this.religionId,
      this.nurtured,
      this.livedInGroup,
      this.cook,
      this.personalityTrength,
      this.personalityWeakness,
      this.hobby,
      this.personalityAssessment,
      this.specialize,
      this.reasonGoJapan,
      this.japanVisaApplied,
      this.personalIncome,
      this.familyIncome,
      this.abroadEver,
      this.abroadCountryId,
      this.abroadCountryDate,
      this.desiredIncome,
      this.desiredIncome3Years,
      this.cumulativePoint,
      this.iqPoint,
      this.workTime,
      this.workAddress,
      this.desiredProfessionJapanDescription,
      this.workAfterContractExpired,
      this.familyAgreement,
      this.jobId});

  factory TTSFormChiTiet.fromJson(Map<String, dynamic> json) {
    return TTSFormChiTiet(
      id: json['id'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      formId: json['formId'],
      // form : json['form'] != null ? new Form.fromJson(json['form']) : null,
      ttsId: json['ttsId'],
      // nguoidung = json['nguoidung'] != null ? new Nguoidung.fromJson(json['nguoidung']) : null,
      academicId: json['academicId'],
      trinhdohocvan: json['trinhdohocvan'] != null ? new Certificate.fromJson(json['trinhdohocvan']) : null,
      folkId: json['folkId'],
      dantoc: json['dantoc'] != null ? new PolkData.fromJson(json['dantoc']) : null,
      religionId: json['religionId'],
      nurtured: json['nurtured'],
      livedInGroup: json['livedInGroup'],
      cook: json['cook'],
      personalityTrength: json['personalityTrength'],
      personalityWeakness: json['personalityWeakness'],
      hobby: json['hobby'],
      personalityAssessment: json['personalityAssessment'],
      specialize: json['specialize'],
      reasonGoJapan: json['reasonGoJapan'],
      japanVisaApplied: json['japanVisaApplied'],
      personalIncome: json['personalIncome'],
      familyIncome: json['familyIncome'],
      abroadEver: json['abroadEver'],
      abroadCountryId: json['abroadCountryId'],
      abroadCountryDate: json['abroadCountryDate'],
      desiredIncome: json['desiredIncome'],
      desiredIncome3Years: json['desiredIncome3Years'],
      cumulativePoint: json['cumulativePoint'],
      iqPoint: json['iqPoint'],
      workTime: json['workTime'],
      workAddress: json['workAddress'],
      desiredProfessionJapanDescription: json['desiredProfessionJapanDescription'],
      workAfterContractExpired: json['workAfterContractExpired'],
      familyAgreement: json['familyAgreement'],
      jobId: json['jobId'],
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
    data['formId'] = this.formId;
    // if (this.form != null) {
    //   data['form'] = this.form!.toJson();
    // }
    data['ttsId'] = this.ttsId;
    // if (this.nguoidung != null) {
    //   data['nguoidung'] = this.nguoidung!.toJson();
    // }
    data['academicId'] = this.academicId;
    // if (this.trinhdohocvan != null) {
    //   data['trinhdohocvan'] = this.trinhdohocvan!.toJson();
    // }
    data['folkId'] = this.folkId;
    // if (this.dantoc != null) {
    //   data['dantoc'] = this.dantoc!.toJson();
    // }
    data['religionId'] = this.religionId;
    data['nurtured'] = this.nurtured;
    data['livedInGroup'] = this.livedInGroup;
    data['cook'] = this.cook;
    data['personalityTrength'] = this.personalityTrength;
    data['personalityWeakness'] = this.personalityWeakness;
    data['hobby'] = this.hobby;
    data['personalityAssessment'] = this.personalityAssessment;
    data['specialize'] = this.specialize;
    data['reasonGoJapan'] = this.reasonGoJapan;
    data['japanVisaApplied'] = this.japanVisaApplied;
    data['personalIncome'] = this.personalIncome;
    data['familyIncome'] = this.familyIncome;
    data['abroadEver'] = this.abroadEver;
    data['abroadCountryId'] = this.abroadCountryId;
    data['abroadCountryDate'] = this.abroadCountryDate;
    data['desiredIncome'] = this.desiredIncome;
    data['desiredIncome3Years'] = this.desiredIncome3Years;
    data['cumulativePoint'] = this.cumulativePoint;
    data['iqPoint'] = this.iqPoint;
    data['workTime'] = this.workTime;
    data['workAddress'] = this.workAddress;
    data['desiredProfessionJapanDescription'] = this.desiredProfessionJapanDescription;
    data['workAfterContractExpired'] = this.workAfterContractExpired;
    data['familyAgreement'] = this.familyAgreement;
    data['jobId'] = this.jobId;
    return data;
  }
}
