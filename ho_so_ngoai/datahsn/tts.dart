import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/trangthai_tts.dart';
import 'package:gentelella_flutter/model/market_development/order.dart';

class Tts {
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
  int? ttsStatusId; // trạng thái tts
  TrangThai? ttsStatusTTS;
  String? phone;
  String? mobile;
  String? email;
  String? address;
  String? hometown;
  String? residence;
  String? avatar;
  int? departId; //phòng ban
  // Phongban? phongban;
  int? teamId; //nhóm thuộc phòng ban
  // Phongban? doinhom;
  int? dutyId; //vai trò
  // Vaitro? vaitro;
  int? isTts;
  int? isCtv;
  int? isAam;
  int? active;
  int? formId;
  String? idCardNo;
  String? issuedDate;
  String? issuedBy;
  int? maritalStatus;
  String? phone2;
  String? email2;
  String? bankAccountName;
  String? bankNumber;
  String? bankName;
  String? bankBranch;
  int? represent;
  int? recommendUser;
  // Nguoigioithieu? nguoigioithieu;
  int? careUser;
  // Nhanvientuyendung? nhanvientuyendung;
  String? qrcodeUrl;
  String? loginTime;
  String? deviceId;
  int? isBlocked;
  String? blockedReason;
  int? orderId; // đơn hàng
  Order? order;
  bool? profileDocumentsCompleted;
  bool? entryDocumentsCompleted;
  int? stopProcessing;
  String? departureDate;
  String? contractExpireDate;
  String? resetPasswordToken;
  Tts({
    this.id,
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
    this.ttsStatusId, //trạng thái
    this.ttsStatusTTS,
    this.phone,
    this.mobile,
    this.email,
    this.address,
    this.hometown,
    this.residence,
    this.avatar,
    this.departId, //phòng ban
    // this.phongban,
    this.teamId, //nhóm thuộc phòng ban
    // this.doinhom,
    this.dutyId, //vai trò
    // this.vaitro,
    this.isTts,
    this.isCtv,
    this.isAam,
    this.active,
    this.formId,
    this.idCardNo,
    this.issuedDate,
    this.issuedBy,
    this.maritalStatus,
    this.phone2,
    this.email2,
    this.bankAccountName,
    this.bankNumber,
    this.bankName,
    this.bankBranch,
    this.represent,
    this.recommendUser,
    // this.nguoigioithieu,
    this.careUser,
    // this.nhanvientuyendung,
    this.qrcodeUrl,
    this.loginTime,
    this.deviceId,
    this.isBlocked,
    this.blockedReason,
    this.orderId, //đơn hàng
    this.order,
    this.profileDocumentsCompleted,
    this.entryDocumentsCompleted,
    this.stopProcessing,
    this.departureDate,
    this.contractExpireDate,
    this.resetPasswordToken,
  });

  factory Tts.fromJson(Map<dynamic, dynamic> json) {
    return Tts(
      id: json['id'] ?? 0,
      modifiedUser: json['modifiedUser'] ?? null,
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'] ?? null,
      createdDate: json['createdDate'] ?? "",
      deleted: json['deleted'] ?? false,
      userCode: json['userCode'] ?? "",
      userName: json['userName'] ?? "",
      fullName: json['fullName'] ?? "",
      gender: json['gender'] ?? 0,
      birthDate: json['birthDate'] ?? "",
      age: json['age'] ?? null,
      ttsStatusId: json['ttsStatusId'] ?? null,
      ttsStatusTTS: json['ttsTrangthai'] != null ? new TrangThai.fromJson(json['ttsTrangthai']) : null,
      phone: json['phone'] ?? "",
      mobile: json['mobile'] ?? "",
      email: json['email'] ?? "",
      address: json['address'] ?? "",
      hometown: json['hometown'] ?? "",
      residence: json['residence'] ?? "",
      avatar: json['avatar'] ?? "",
      departId: json['departId'] ?? null,
      isTts: json['isTts'] ?? null,
      isCtv: json['isCtv'] ?? null,
      isAam: json['isAam'] ?? null,
      active: json['active'] ?? null,
      formId: json['formId'] ?? null,
      idCardNo: json['idCardNo'] ?? "",
      issuedDate: json['issuedDate'] ?? "",
      issuedBy: json['issuedBy'] ?? "",
      maritalStatus: json['maritalStatus'] ?? null,
      phone2: json['phone2'] ?? "",
      email2: json['email2'] ?? "",
      bankAccountName: json['bankAccountName'] ?? "",
      bankNumber: json['bankNumber'] ?? "",
      bankName: json['bankName'] ?? "",
      bankBranch: json['bankBranch'] ?? "",
      represent: json['represent'] ?? null,
      recommendUser: json['recommendUser'] ?? null,
      // nguoigioithieu: json['nguoigioithieu'] != null ? new Nguoigioithieu.fromJson(json['nguoigioithieu']) : null,
      careUser: json['careUser'] ?? null,
      qrcodeUrl: json['qrcodeUrl'] ?? "",
      loginTime: json['loginTime'] ?? "",
      deviceId: json['deviceId'] ?? "",
      isBlocked: json['isBlocked'] ?? null,
      blockedReason: json['blockedReason'] ?? "",
      orderId: json['orderId'] ?? null,
      order: json['donhang'] != null ? new Order.fromJson(json['donhang']) : null,
      entryDocumentsCompleted: json['entryDocumentsCompleted'] ?? false,
      stopProcessing: json['stopProcessing'] ?? null,
      departureDate: json['departureDate'] ?? "-----------",
      contractExpireDate: json['contractExpireDate'] ?? "",
      resetPasswordToken: json['resetPasswordToken'] ?? "",
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
    // if (this.ttsStatusTTS != null) {
    //   data['ttsTrangthai'] = this.ttsStatusTTS!.toJson();
    // }
    data['phone'] = this.phone;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['address'] = this.address;
    data['hometown'] = this.hometown;
    data['residence'] = this.residence;
    data['avatar'] = this.avatar;
    data['departId'] = this.departId;
    // if (this.phongban != null) {
    //   data['phongban'] = this.phongban!.toJson();
    // }
    data['teamId'] = this.teamId;
    // if (this.doinhom != null) {
    //   data['doinhom'] = this.doinhom!.toJson();
    // }
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
    // if (this.order != null) {
    //   data['donhang'] = this.order!.toJson();
    // }
    data['profileDocumentsCompleted'] = this.profileDocumentsCompleted;
    data['entryDocumentsCompleted'] = this.entryDocumentsCompleted;
    data['stopProcessing'] = this.stopProcessing;
    data['departureDate'] = this.departureDate;
    data['contractExpireDate'] = this.contractExpireDate;
    data['resetPasswordToken'] = this.resetPasswordToken;
    return data;
  }
}
