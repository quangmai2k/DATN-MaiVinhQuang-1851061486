import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import '../../../../model/market_development/order.dart';
import '../../../forms/nhan_su/setting-data/folk.dart';
import '../../../forms/nhan_su/setting-data/religion.dart';

class TTS {
  int? id;
  String? userCode;
  String? userName;
  String? fullName;
  String? avatar;
  DateTime? birthDate;
  StatusTTS? ttsStatus;
  int? gender;
  String? phone;
  String? mobile;
  String? email;
  String? address;
  String? hometown;
  String? residence;
  int? maritalStatus;
  String? idCardNo;
  DateTime? issuedDate;
  String? issuedBy;
  UserAAM? careUser;
  Order? order;
  int? stopProcessing;
  DateTime? departureDate;
  DateTime? contractExpireDate;
  String? resetPasswordToken;
  //form chi tiết
  TTSForm? ttsForm;
  TrinhdoHocVan? trinhDoHocVan;
  Folk? dantoc;
  Religion? tongiao;
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
  DateTime? abroadCountryDate;
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
  //Bảng sức khỏe
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
  DateTime? examCheckDate;
  DateTime? flightCheckDate;
  int? examHealthCheckResult;
  int? flightHealthCheckResult;
  int? pcrTestResult;
  String? rightEyesight;
  String? leftEyesight;
  DateTime? pcrTestDate;
  UserAAM? recommendUser;

  //Qua trình học tập
  List<QuaTrinhHocTap>? quaTrinhHocTap;
  //Trifnhtrajng học tập
  List<TinhTrangHocTap>? tinhTrangHocTap;
  //QKinh nghiệm làm việc
  List<KinhNghiemLamViec>? kinhNghiemLamViec;
  //Thành phần gia đình
  List<ThanhPhanGiaDinh>? thanhPhanGiaDinh;
  //Ngành nghề mong muốn
  List<NganhNghe>? nganhNgheMongMuon;
  //Liên hệ khẩn cấp
  LienHeKhanCap? lienHeKhanCap;
  //TRình độ máy tính
  TrinhDoMayTinh? trinhDoMayTinh;
  TrinhDoNgoaiNgu? trinhDoNgoaiNgu;
  List<TrinhDoHocVan>? trinhDoHocVanKiSu;

  TTS({
    this.id,
    this.userCode,
    this.userName,
    this.fullName,
    this.avatar,
    this.birthDate,
    this.ttsStatus,
    this.phone,
    this.mobile,
    this.email,
    this.address,
    this.hometown,
    this.residence,
    this.maritalStatus,
    this.idCardNo,
    this.issuedDate,
    this.issuedBy,
    this.careUser,
    this.gender,
    this.order,
    this.stopProcessing,
    this.departureDate,
    this.contractExpireDate,
    this.resetPasswordToken,
    this.ttsForm,
    this.trinhDoHocVan,
    this.dantoc,
    this.tongiao,
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
    this.jobId,
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
    this.quaTrinhHocTap,
    this.tinhTrangHocTap,
    this.kinhNghiemLamViec,
    this.thanhPhanGiaDinh,
    this.nganhNgheMongMuon,
    this.lienHeKhanCap,
    this.trinhDoMayTinh,
    this.trinhDoNgoaiNgu,
    this.trinhDoHocVanKiSu,
    this.recommendUser,
    this.leftEyesight,
    this.rightEyesight,
  });
}

class StatusTTS {
  int? id;
  String? statusName;
  int? active;

  StatusTTS({
    this.id,
    this.statusName,
    this.active,
  });
}

class TTSForm {
  int? id;
  String? formName;
  String? description;

  TTSForm({
    this.id,
    this.formName,
    this.description,
  });
}

class TrinhdoHocVan {
  int? id;
  String? name;
  String? description;

  TrinhdoHocVan({
    this.id,
    this.name,
    this.description,
  });
}

class QuaTrinhHocTap {
  int? id;
  String? schoolName;
  String? specialized;
  String? certificate;
  String? address;
  DateTime? dateFrom;
  DateTime? dateTo;

  QuaTrinhHocTap({
    this.id,
    this.schoolName,
    this.specialized,
    this.certificate,
    this.address,
    this.dateFrom,
    this.dateTo,
  });
}

class TinhTrangHocTap {
  int? id;
  int? lateAdmission;
  int? earlyAdmission;
  int? repetitionAdmission;
  String? yearAdmission;

  TinhTrangHocTap({
    this.id,
    this.lateAdmission,
    this.earlyAdmission,
    this.repetitionAdmission,
    this.yearAdmission,
  });
}

class QuaTrinhLamViec {
  int? id;
  int? orderId;
  int? violateId;
  String? issuedContent;
  String? handleResult;
  DateTime? issuedDate;
  DateTime? handleDate;

  QuaTrinhLamViec({
    this.id,
    this.orderId,
    this.violateId,
    this.issuedContent,
    this.handleResult,
    this.issuedDate,
    this.handleDate,
  });
}

class ThanhPhanGiaDinh {
  int? id;
  String? fullName;
  String? relation;
  DateTime? birthDate;
  String? job;
  int? livingTogether;
  int? japanVisaApplied;

  ThanhPhanGiaDinh({
    this.id,
    this.fullName,
    this.relation,
    this.birthDate,
    this.job,
    this.livingTogether,
    this.japanVisaApplied,
  });
}

class KinhNghiemLamViec {
  int? id;
  String? companyName;
  String? workContent;
  DateTime? dateFrom;
  DateTime? dateTo;

  KinhNghiemLamViec({
    this.id,
    this.companyName,
    this.workContent,
    this.dateFrom,
    this.dateTo,
  });
}

class NganhNghe {
  int? id;
  String? jobName;

  NganhNghe({
    this.id,
    this.jobName,
  });
}

class TTSHoSoChiTiet {
  int? id;
  int? hosoId;
  String? hosoName;
  String? content;
  String? fileUrl;
  int? received;
  int? times;

  TTSHoSoChiTiet({
    this.id,
    this.hosoId,
    this.hosoName,
    this.content,
    this.fileUrl,
    this.received,
    this.times,
  });
}

class LienHeKhanCap {
  int? id;
  String? name;
  String? address;
  String? relation;
  String? phone;
  String? facebook;
  String? skype;

  LienHeKhanCap({
    this.id,
    this.name,
    this.address,
    this.relation,
    this.phone,
    this.facebook,
    this.skype,
  });
}

class TrinhDoMayTinh {
  int? id;
  int? internetEmail;
  int? msWord;
  int? msExcel;
  int? autoCad;
  int? cam;
  int? catia;
  int? otherType;
  String? otherName;
  int? otherLevel;

  TrinhDoMayTinh({
    this.id,
    this.internetEmail,
    this.msWord,
    this.msExcel,
    this.autoCad,
    this.cam,
    this.catia,
    this.otherType,
    this.otherName,
    this.otherLevel,
  });
}

class TrinhDoNgoaiNgu {
  int? id;
  int? english;
  int? japanese;

  TrinhDoNgoaiNgu({
    this.id,
    this.english,
    this.japanese,
  });
}

class TrinhDoHocVan {
  int? id;
  int? ttsId;
  TrinhdoHocVan? academy;
  String? description;
  DateTime? issueDate;

  TrinhDoHocVan({
    this.id,
    this.ttsId,
    this.academy,
    this.description,
    this.issueDate,
  });
}
// //Tiến cử đơn hàng view 
// class TienCuDonHang {
//   int? id;
//   String? name;
//   String? address;
//   String? relation;
//   String? phone;

//   LienHeKhanCap({
//     this.id,
//     this.name,
//     this.address,
//     this.relation,
//     this.phone,
//   });
// }
