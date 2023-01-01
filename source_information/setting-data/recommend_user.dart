// import 'care_user.dart';
// import 'tts_status.dart';

// class Nguoigioithieu {
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
//   int? ttsStatusId;
//   TtsTrangthai? ttsTrangthai;
//   String? phone;
//   String? mobile;
//   String? email;
//   String? address;
//   String? hometown;
//   String? residence;
//   String? avatar;
//   int? departId;
//   // PhongBan? phongban;
//   int? teamId;
//   // Null? doinhom;
//   int? dutyId;
//   // Null? vaitro;
//   int? isTts;
//   int? isCtv;
//   int? isAam;
//   int? active;
//   Null? formId;
//   Null? idCardNo;
//   Null? issuedDate;
//   Null? issuedBy;
//   Null? maritalStatus;
//   String? phone2;
//   String? email2;
//   String? bankAccountName;
//   String? bankNumber;
//   String? bankName;
//   String? bankBranch;
//   int? represent;
//   int? recommendUser;
//   // Null? nguoigioithieu;
//   int? careUser;
//   // Nhanvientuyendung? nhanvientuyendung;
//   String? qrcodeUrl;
//   String? loginTime;
//   String? deviceId;
//   int? isBlocked;
//   String? blockedReason;
//   int? orderId;
//   // Null? donhang;
//   bool? profileDocumentsCompleted;
//   bool? entryDocumentsCompleted;
//   int? stopProcessing;
//   String? departureDate;
//   Null? contractExpireDate;
//   String? resetPasswordToken;
//   List<Null>? roles;

//   Nguoigioithieu(
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
//       this.roles});

//   Nguoigioithieu.fromJson(Map<String, dynamic> json) {
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
//     ttsTrangthai = json['ttsTrangthai'] != null
//         ? new TtsTrangthai.fromJson(json['ttsTrangthai'])
//         : null;
//     phone = json['phone'];
//     mobile = json['mobile'];
//     email = json['email'];
//     address = json['address'];
//     hometown = json['hometown'];
//     residence = json['residence'];
//     avatar = json['avatar'];
//     departId = json['departId'];
//     phongban = json['phongban'];
//     teamId = json['teamId'];
//     doinhom = json['doinhom'];
//     dutyId = json['dutyId'];
//     vaitro = json['vaitro'];
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
//     nhanvientuyendung = json['nhanvientuyendung'] != null
//         ? new Nhanvientuyendung.fromJson(json['nhanvientuyendung'])
//         : null;
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
//     //   roles = <Null>[];
//     //   json['roles'].forEach((v) {
//     //     roles!.add(new Null.fromJson(v));
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
//     if (this.ttsTrangthai != null) {
//       data['ttsTrangthai'] = this.ttsTrangthai!.toJson();
//     }
//     data['phone'] = this.phone;
//     data['mobile'] = this.mobile;
//     data['email'] = this.email;
//     data['address'] = this.address;
//     data['hometown'] = this.hometown;
//     data['residence'] = this.residence;
//     data['avatar'] = this.avatar;
//     data['departId'] = this.departId;
//     data['phongban'] = this.phongban;
//     data['teamId'] = this.teamId;
//     data['doinhom'] = this.doinhom;
//     data['dutyId'] = this.dutyId;
//     data['vaitro'] = this.vaitro;
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
//     if (this.nhanvientuyendung != null) {
//       data['nhanvientuyendung'] = this.nhanvientuyendung!.toJson();
//     }
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
//     //   data['roles'] = this.roles!.map((v) => v!.toJson()).toList();
//     // }
//     return data;
//   }
// }
