// import 'depart.dart';
// import 'duty.dart';

// class Nhanvientuyendung {
//   int? id;
//   int? modifiedUser;
//   String? modifiedDate;
//   int? createdUser;
//   String? createdDate;
//   String? userCode;
//   String? userName;
//   String? password;
//   String? fullName;
//   int? gender;
//   String? birthDate;
//   int? age;
//   Null? ttsStatusId;
//   Null? ttsTrangthai;
//   String? phone;
//   Null? mobile;
//   String? email;
//   String? address;
//   String? hometown;
//   String? residence;
//   String? avatar;
//   int? departId;
//   Phongban? phongban;
//   Null? teamId;
//   Null? doinhom;
//   int? dutyId;
//   Vaitro? vaitro;
//   Null? isTts;
//   Null? isCtv;
//   int? isAam;
//   int? active;
//   Null? formId;
//   String? idCardNo;
//   Null? issuedDate;
//   String? issuedBy;
//   int? maritalStatus;
//   Null? phone2;
//   Null? email2;
//   Null? bankAccountName;
//   Null? bankNumber;
//   Null? bankName;
//   Null? bankBranch;
//   Null? represent;
//   Null? recommendUser;
//   Null? nguoigioithieu;
//   Null? careUser;
//   Null? nhanvientuyendung;
//   String? qrcodeUrl;
//   Null? loginTime;
//   Null? deviceId;
//   int? isBlocked;
//   Null? blockedReason;
//   Null? orderId;
//   Null? donhang;
//   bool? profileDocumentsCompleted;
//   bool? entryDocumentsCompleted;
//   int? stopProcessing;
//   Null? departureDate;
//   Null? contractExpireDate;
//   Null? resetPasswordToken;
//   // List<Roles>? roles;

//   Nhanvientuyendung(
//       {this.id,
//       this.modifiedUser,
//       this.modifiedDate,
//       this.createdUser,
//       this.createdDate,
//       this.userCode,
//       this.userName,
//       this.password,
//       this.fullName,
//       this.gender,
//       this.birthDate,
//       this.age,
//       this.ttsStatusId,
//       this.ttsTrangthai,
//       this.phone,
//       this.mobile,
//       this.email,
//       this.address,
//       this.hometown,
//       this.residence,
//       this.avatar,
//       this.departId,
//       this.phongban,
//       this.teamId,
//       this.doinhom,
//       this.dutyId,
//       this.vaitro,
//       this.isTts,
//       this.isCtv,
//       this.isAam,
//       this.active,
//       this.formId,
//       this.idCardNo,
//       this.issuedDate,
//       this.issuedBy,
//       this.maritalStatus,
//       this.phone2,
//       this.email2,
//       this.bankAccountName,
//       this.bankNumber,
//       this.bankName,
//       this.bankBranch,
//       this.represent,
//       this.recommendUser,
//       this.nguoigioithieu,
//       this.careUser,
//       this.nhanvientuyendung,
//       this.qrcodeUrl,
//       this.loginTime,
//       this.deviceId,
//       this.isBlocked,
//       this.blockedReason,
//       this.orderId,
//       this.donhang,
//       this.profileDocumentsCompleted,
//       this.entryDocumentsCompleted,
//       this.stopProcessing,
//       this.departureDate,
//       this.contractExpireDate,
//       this.resetPasswordToken,
//       // this.roles,
//       });

//   Nhanvientuyendung.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     modifiedUser = json['modifiedUser'];
//     modifiedDate = json['modifiedDate'];
//     createdUser = json['createdUser'];
//     createdDate = json['createdDate'];
//     userCode = json['userCode'];
//     userName = json['userName'];
//     password = json['password'];
//     fullName = json['fullName'];
//     gender = json['gender'];
//     birthDate = json['birthDate'];
//     age = json['age'];
//     ttsStatusId = json['ttsStatusId'];
//     ttsTrangthai = json['ttsTrangthai'];
//     phone = json['phone'];
//     mobile = json['mobile'];
//     email = json['email'];
//     address = json['address'];
//     hometown = json['hometown'];
//     residence = json['residence'];
//     avatar = json['avatar'];
//     departId = json['departId'];
//     phongban = json['phongban'] != null ? new Phongban.fromJson(json['phongban']) : null;
//     teamId = json['teamId'];
//     doinhom = json['doinhom'];
//     dutyId = json['dutyId'];
//     vaitro = json['vaitro'] != null ? new Vaitro.fromJson(json['vaitro']) : null;
//     isTts = json['isTts'];
//     isCtv = json['isCtv'];
//     isAam = json['isAam'];
//     active = json['active'];
//     formId = json['formId'];
//     idCardNo = json['idCardNo'];
//     issuedDate = json['issuedDate'];
//     issuedBy = json['issuedBy'];
//     maritalStatus = json['maritalStatus'];
//     phone2 = json['phone2'];
//     email2 = json['email2'];
//     bankAccountName = json['bankAccountName'];
//     bankNumber = json['bankNumber'];
//     bankName = json['bankName'];
//     bankBranch = json['bankBranch'];
//     represent = json['represent'];
//     recommendUser = json['recommendUser'];
//     nguoigioithieu = json['nguoigioithieu'];
//     careUser = json['careUser'];
//     nhanvientuyendung = json['nhanvientuyendung'];
//     qrcodeUrl = json['qrcodeUrl'];
//     loginTime = json['loginTime'];
//     deviceId = json['deviceId'];
//     isBlocked = json['isBlocked'];
//     blockedReason = json['blockedReason'];
//     orderId = json['orderId'];
//     donhang = json['donhang'];
//     profileDocumentsCompleted = json['profileDocumentsCompleted'];
//     entryDocumentsCompleted = json['entryDocumentsCompleted'];
//     stopProcessing = json['stopProcessing'];
//     departureDate = json['departureDate'];
//     contractExpireDate = json['contractExpireDate'];
//     resetPasswordToken = json['resetPasswordToken'];
//     // if (json['roles'] != null) {
//     //   roles = <Roles>[];
//     //   json['roles'].forEach((v) {
//     //     roles!.add(new Roles.fromJson(v));
//     //   });
//     // }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['modifiedUser'] = this.modifiedUser;
//     data['modifiedDate'] = this.modifiedDate;
//     data['createdUser'] = this.createdUser;
//     data['createdDate'] = this.createdDate;
//     data['userCode'] = this.userCode;
//     data['userName'] = this.userName;
//     data['password'] = this.password;
//     data['fullName'] = this.fullName;
//     data['gender'] = this.gender;
//     data['birthDate'] = this.birthDate;
//     data['age'] = this.age;
//     data['ttsStatusId'] = this.ttsStatusId;
//     data['ttsTrangthai'] = this.ttsTrangthai;
//     data['phone'] = this.phone;
//     data['mobile'] = this.mobile;
//     data['email'] = this.email;
//     data['address'] = this.address;
//     data['hometown'] = this.hometown;
//     data['residence'] = this.residence;
//     data['avatar'] = this.avatar;
//     data['departId'] = this.departId;
//     if (this.phongban != null) {
//       data['phongban'] = this.phongban!.toJson();
//     }
//     data['teamId'] = this.teamId;
//     data['doinhom'] = this.doinhom;
//     data['dutyId'] = this.dutyId;
//     if (this.vaitro != null) {
//       data['vaitro'] = this.vaitro!.toJson();
//     }
//     data['isTts'] = this.isTts;
//     data['isCtv'] = this.isCtv;
//     data['isAam'] = this.isAam;
//     data['active'] = this.active;
//     data['formId'] = this.formId;
//     data['idCardNo'] = this.idCardNo;
//     data['issuedDate'] = this.issuedDate;
//     data['issuedBy'] = this.issuedBy;
//     data['maritalStatus'] = this.maritalStatus;
//     data['phone2'] = this.phone2;
//     data['email2'] = this.email2;
//     data['bankAccountName'] = this.bankAccountName;
//     data['bankNumber'] = this.bankNumber;
//     data['bankName'] = this.bankName;
//     data['bankBranch'] = this.bankBranch;
//     data['represent'] = this.represent;
//     data['recommendUser'] = this.recommendUser;
//     data['nguoigioithieu'] = this.nguoigioithieu;
//     data['careUser'] = this.careUser;
//     data['nhanvientuyendung'] = this.nhanvientuyendung;
//     data['qrcodeUrl'] = this.qrcodeUrl;
//     data['loginTime'] = this.loginTime;
//     data['deviceId'] = this.deviceId;
//     data['isBlocked'] = this.isBlocked;
//     data['blockedReason'] = this.blockedReason;
//     data['orderId'] = this.orderId;
//     data['donhang'] = this.donhang;
//     data['profileDocumentsCompleted'] = this.profileDocumentsCompleted;
//     data['entryDocumentsCompleted'] = this.entryDocumentsCompleted;
//     data['stopProcessing'] = this.stopProcessing;
//     data['departureDate'] = this.departureDate;
//     data['contractExpireDate'] = this.contractExpireDate;
//     data['resetPasswordToken'] = this.resetPasswordToken;
//     // if (this.roles != null) {
//     //   data['roles'] = this.roles!.map((v) => v.toJson()).toList();
//     // }
//     return data;
//   }
// }
