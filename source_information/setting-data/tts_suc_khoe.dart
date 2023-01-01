class SucKhoeData {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  int? ttsId;
  int? formId;
  int? eyeSight;
  int? rightHanded;
  int? leftHanded;
  int? height;
  int? weight;
  int? colorBlind;
  int? bloodGroup;
  int? everSurgery;
  int? tatoo;
  int? drinkAlcohol;
  int? smoke;
  String? hearing;
  int? healthStatus;
  String? pastPathology;
  String? currentPathology;
  int? familyMedicalHistory;
  int? malformation;
  int? covidInjection;
  String? examHealthCertificate;
  String? flightHealthCertificate;
  String? examCheckDate;
  String? flightCheckDate;
  int? examHealthCheckResult;
  int? flightHealthCheckResult;
  int? pcrTestResult;
  String? pcrTestDate;
  String? rightEyesight;
  String? leftEyesight;

  SucKhoeData({
    this.id,
    this.modifiedUser,
    this.modifiedDate,
    this.createdUser,
    this.createdDate,
    this.deleted,
    this.ttsId,
    this.formId,
    this.eyeSight,
    this.rightHanded,
    this.leftHanded,
    this.height,
    this.weight,
    this.colorBlind,
    this.bloodGroup,
    this.everSurgery,
    this.tatoo,
    this.drinkAlcohol,
    this.smoke,
    this.hearing,
    this.healthStatus,
    this.pastPathology,
    this.currentPathology,
    this.familyMedicalHistory,
    this.malformation,
    this.covidInjection,
    this.examHealthCertificate,
    this.flightHealthCertificate,
    this.examCheckDate,
    this.flightCheckDate,
    this.examHealthCheckResult,
    this.flightHealthCheckResult,
    this.pcrTestResult,
    this.pcrTestDate,
    this.rightEyesight,
    this.leftEyesight,
  });

  factory SucKhoeData.fromJson(Map<String, dynamic> json) {
    return SucKhoeData(
      id: json['id'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'],
      createdDate: json['createdDate'] ?? "",
      deleted: json['deleted'] ?? false,
      ttsId: json['ttsId'],
      formId: json['formId'],
      eyeSight: json['eyeSight'] ?? 0,
      rightHanded: json['rightHanded'],
      leftHanded: json['leftHanded'],
      height: json['height'],
      weight: json['weight'],
      colorBlind: json['colorBlind'],
      bloodGroup: json['bloodGroup'],
      everSurgery: json['everSurgery'],
      tatoo: json['tatoo'],
      drinkAlcohol: json['drinkAlcohol'],
      smoke: json['smoke'],
      hearing: json['hearing'] ?? "",
      healthStatus: json['healthStatus'],
      pastPathology: json['pastPathology'] ?? "",
      currentPathology: json['currentPathology'] ?? "",
      familyMedicalHistory: json['familyMedicalHistory'],
      malformation: json['malformation'],
      covidInjection: json['covidInjection'],
      examHealthCertificate: json['examHealthCertificate'] ?? "",
      flightHealthCertificate: json['flightHealthCertificate'] ?? "",
      examCheckDate: json['examCheckDate'] ?? "",
      flightCheckDate: json['flightCheckDate'] ?? "",
      examHealthCheckResult: json['examHealthCheckResult'],
      flightHealthCheckResult: json['flightHealthCheckResult'],
      pcrTestResult: json['pcrTestResult'],
      pcrTestDate: json['pcrTestDate'] ?? "",
      rightEyesight: json['rightEyesight'],
      leftEyesight: json['leftEyesight'],
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
    data['formId'] = this.formId;
    data['eyeSight'] = this.eyeSight;
    data['rightHanded'] = this.rightHanded;
    data['leftHanded'] = this.leftHanded;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['colorBlind'] = this.colorBlind;
    data['bloodGroup'] = this.bloodGroup;
    data['everSurgery'] = this.everSurgery;
    data['tatoo'] = this.tatoo;
    data['drinkAlcohol'] = this.drinkAlcohol;
    data['smoke'] = this.smoke;
    data['hearing'] = this.hearing;
    data['healthStatus'] = this.healthStatus;
    data['pastPathology'] = this.pastPathology;
    data['currentPathology'] = this.currentPathology;
    data['familyMedicalHistory'] = this.familyMedicalHistory;
    data['malformation'] = this.malformation;
    data['covidInjection'] = this.covidInjection;
    data['examHealthCertificate'] = this.examHealthCertificate;
    data['flightHealthCertificate'] = this.flightHealthCertificate;
    data['examCheckDate'] = this.examCheckDate;
    data['flightCheckDate'] = this.flightCheckDate;
    data['examHealthCheckResult'] = this.examHealthCheckResult;
    data['flightHealthCheckResult'] = this.flightHealthCheckResult;
    data['pcrTestResult'] = this.pcrTestResult;
    data['pcrTestDate'] = this.pcrTestDate;
    data['rightEyesight'] = this.rightEyesight;
    data['leftEyesight'] = this.leftEyesight;
    return data;
  }
}
