import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/form_id.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/tts_status.dart';
import 'package:intl/intl.dart';

import 'depart.dart';
class InformationTTS {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? userCode;
  String? userName;
  String? fullName;
  int? gender;
  String? birthDate;
  int? age;
  int? ttsStatusId;
  TtsTrangthai? ttsTrangthai;
  String? phone;
  String? mobile;
  String? email;
  String? address;
  String? hometown;
  String? residence;
  String? avatar;
  int? departId;
  Phongban? phongban;
  int? teamId;
  Phongban? doinhom;
  int? dutyId;
  // Vaitro? vaitro;
  int? isTts;
  int? isCtv;
  int? isAam;
  int? active;
  int? formId;
  FormId? form;

  String? idCardNo;
  String? issuedDate;
  String? issuedBy;
  String? idCardImageFront;
  String? idCardImageBack;
  int? maritalStatus;
  String? phone2;
  String? email2;
  String? bankAccountName;
  String? bankNumber;
  String? bankName;
  String? bankBranch;
  int? represent;
  int? recommendUser;
  InformationTTS? nguoigioithieu;
  int? careUserTemp;
  // Nguoigioithieu? nguoigioithieu;
  int? careUser;
  InformationTTS? nhanvientuyendung;
  String? qrcodeUrl;
  String? loginTime;
  String? deviceId;
  int? isBlocked;
  String? blockedReason;
  int? orderId;
  // Donhang? donhang;
  bool? profileDocumentsCompleted;
  bool? entryDocumentsCompleted;
  int? stopProcessing;
  String? departureDate;
  String? contractExpireDate;
  String? resetPasswordToken;

  InformationTTS(
      {this.id,
      this.modifiedUser,
      this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.userCode,
      this.userName,
      this.fullName,
      this.gender,
      this.birthDate,
      this.age,
      this.ttsStatusId,
      this.ttsTrangthai,
      this.phone,
      this.mobile,
      this.email,
      this.address,
      this.hometown,
      this.residence,
      this.avatar,
      this.departId,
      this.phongban,
      this.teamId,
      this.doinhom,
      this.dutyId,
      // this.vaitro,
      this.isTts,
      this.isCtv,
      this.isAam,
      this.active,
      this.formId,
      this.form,
      this.idCardNo,
      this.issuedDate,
      this.issuedBy,
      this.idCardImageFront,
      this.idCardImageBack,
      this.maritalStatus,
      this.phone2,
      this.email2,
      this.bankAccountName,
      this.bankNumber,
      this.bankName,
      this.bankBranch,
      this.represent,
      this.recommendUser,
      this.nguoigioithieu,
      this.careUser,
      this.nhanvientuyendung,
      this.qrcodeUrl,
      this.loginTime,
      this.deviceId,
      this.isBlocked,
      this.blockedReason,
      this.orderId,
      // this.donhang,
      this.profileDocumentsCompleted,
      this.entryDocumentsCompleted,
      this.stopProcessing,
      this.departureDate,
      this.contractExpireDate,
      this.resetPasswordToken,
      this.careUserTemp});

  factory InformationTTS.fromJson(Map<String, dynamic> json) {
    return InformationTTS(
      id: json['id'],
      modifiedUser: json['modifiedUser'],
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'],
      createdDate: json['createdDate'] ?? "",
      deleted: json['deleted'] ?? false,
      userCode: json['userCode'] ?? "",
      userName: json['userName'] ?? "",
      fullName: json['fullName'] ?? "",
      gender: json['gender'],
      birthDate: json['birthDate'] ?? "",
      age: json['age'],
      ttsStatusId: json['ttsStatusId'],
      ttsTrangthai: json['ttsTrangthai'] != null ? new TtsTrangthai.fromJson(json['ttsTrangthai']) : null,
      phone: json['phone'] ?? "",
      mobile: json['mobile'] ?? "",
      email: json['email'] ?? "",
      address: json['address'] ?? "",
      hometown: json['hometown'] ?? "",
      residence: json['residence'] ?? "",
      avatar: json['avatar'] ?? "",
      departId: json['departId'],
      phongban: json['phongban'] != null ? new Phongban.fromJson(json['phongban']) : null,
      teamId: json['teamId'],
      doinhom: json['doinhom'] != null ? new Phongban.fromJson(json['doinhom']) : null,
      dutyId: json['dutyId'],
      // vaitro: json['vaitro'] != null ? new Vaitro.fromJson(json['vaitro']) : null,
      isTts: json['isTts'],
      isCtv: json['isCtv'],
      isAam: json['isAam'],
      active: json['active'],
      formId: json['formId'],
      form: json['form'] != null ? new FormId.fromJson(json['form']) : null,
      idCardNo: json['idCardNo'] ?? "",
      issuedDate: json['issuedDate'] ?? "",
      issuedBy: json['issuedBy'] ?? "",

      idCardImageFront: json['idCardImageFront'],
      idCardImageBack: json['idCardImageBack'],

      maritalStatus: json['maritalStatus'],
      phone2: json['phone2'] ?? "",
      email2: json['email2'] ?? "",
      bankAccountName: json['bankAccountName'] ?? "",
      bankNumber: json['bankNumber'] ?? "",
      bankName: json['bankName'] ?? "",
      bankBranch: json['bankBranch'] ?? "",
      represent: json['represent'],
      recommendUser: json['recommendUser'],
      nguoigioithieu: json['nguoigioithieu'] != null ? new InformationTTS.fromJson(json['nguoigioithieu']) : null,
      careUser: json['careUser'],
      nhanvientuyendung: json['nhanvientuyendung'] != null ? new InformationTTS.fromJson(json['nhanvientuyendung']) : null,
      qrcodeUrl: json['qrcodeUrl'] ?? "",
      loginTime: json['loginTime'] ?? "",
      deviceId: json['deviceId'] ?? "",
      isBlocked: json['isBlocked'],
      blockedReason: json['blockedReason'] ?? "",
      orderId: json['orderId'],
      // donhang: json['donhang'] != null ? new Donhang.fromJson(json['donhang']) : null,
      profileDocumentsCompleted: json['profileDocumentsCompleted'] ?? false,
      entryDocumentsCompleted: json['entryDocumentsCompleted'] ?? false,
      stopProcessing: json['stopProcessing'],
      departureDate: json['departureDate'] ?? "",
      contractExpireDate: json['contractExpireDate'] ?? "",
      resetPasswordToken: json['resetPasswordToken'] ?? "",
      careUserTemp: json['careUserTemp'],
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
    data['userCode'] = this.userCode;
    data['userName'] = this.userName;
    data['fullName'] = this.fullName;
    data['gender'] = this.gender;
    data['birthDate'] = this.birthDate;
    data['age'] = this.age;
    data['ttsStatusId'] = this.ttsStatusId;
    if (this.ttsTrangthai != null) {
      data['ttsTrangthai'] = this.ttsTrangthai!.toJson();
    }
    data['phone'] = this.phone;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['address'] = this.address;
    data['hometown'] = this.hometown;
    data['residence'] = this.residence;
    data['avatar'] = this.avatar;
    data['departId'] = this.departId;
    if (this.phongban != null) {
      data['phongban'] = this.phongban!.toJson();
    }
    data['teamId'] = this.teamId;
    if (this.doinhom != null) {
      data['doinhom'] = this.doinhom!.toJson();
    }
    data['dutyId'] = this.dutyId;
    // if (this.vaitro != null) {
    //   data['vaitro'] = this.vaitro!.toJson();
    // }
    data['isTts'] = this.isTts;
    data['isCtv'] = this.isCtv;
    data['isAam'] = this.isAam;
    data['active'] = this.active;
    data['formId'] = this.formId;
    data['idCardNo'] = this.idCardNo;
    data['issuedDate'] = this.issuedDate;
    data['issuedBy'] = this.issuedBy;
    data['maritalStatus'] = this.maritalStatus;
    data['phone2'] = this.phone2;
    data['email2'] = this.email2;
    data['bankAccountName'] = this.bankAccountName;
    data['bankNumber'] = this.bankNumber;
    data['bankName'] = this.bankName;
    data['bankBranch'] = this.bankBranch;
    data['represent'] = this.represent;
    data['recommendUser'] = this.recommendUser;
    // if (this.nguoigioithieu != null) {
    //   data['nguoigioithieu'] = this.nguoigioithieu!.toJson();
    // }
    data['careUser'] = this.careUser;
    // if (this.nhanvientuyendung != null) {
    //   data['nhanvientuyendung'] = this.nhanvientuyendung!.toJson();
    // }
    data['qrcodeUrl'] = this.qrcodeUrl;
    data['loginTime'] = this.loginTime;
    data['deviceId'] = this.deviceId;
    data['isBlocked'] = this.isBlocked;
    data['blockedReason'] = this.blockedReason;
    data['orderId'] = this.orderId;
    // if (this.donhang != null) {
    //   data['donhang'] = this.donhang!.toJson();
    // }
    data['profileDocumentsCompleted'] = this.profileDocumentsCompleted;
    data['entryDocumentsCompleted'] = this.entryDocumentsCompleted;
    data['stopProcessing'] = this.stopProcessing;
    data['departureDate'] = this.departureDate;
    data['contractExpireDate'] = this.contractExpireDate;
    data['resetPasswordToken'] = this.resetPasswordToken;
    data['careUserTemp'] = this.careUserTemp;
    data['idCardImageFront'] = this.idCardImageFront;
    data['idCardImageBack'] = this.idCardImageBack;

    return data;
  }

  String getGender() {
    String nameGender = "";
    if (this.gender == null)
      nameGender = "";
    else {
      switch (this.gender) {
        case 1:
          {
            nameGender = "Nam";
          }
          break;
        case 0:
          {
            nameGender = "Nữ";
          }
          break;
      }
    }
    return nameGender;
  }

  String getYearTTS() {
    String yearTTS = "";
    // print("năm sinh thực tập sinh${}")
    if (this.birthDate != null && this.birthDate != '') {
      yearTTS = DateFormat("dd-MM-yyyy").format(DateTime.parse(this.birthDate!));
    } else {
      yearTTS = "";
    }
    return yearTTS;
  }
}
